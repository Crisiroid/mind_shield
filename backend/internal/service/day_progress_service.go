package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"psychology-backend/internal/interfaces"
	"psychology-backend/internal/models"
	"psychology-backend/internal/repository"
	"psychology-backend/pkg/schemas"

	"gorm.io/gorm"
)

type DayProgressService struct {
	dayProgressRepo interfaces.DayProgressRepositoryInterface
}

func NewDayProgressService(repo interfaces.DayProgressRepositoryInterface) *DayProgressService {
	return &DayProgressService{
		dayProgressRepo: repo,
	}
}

func (s *DayProgressService) CreateDayProgress(ctx context.Context, req *schemas.DayProgressCreateRequest) (*schemas.DayProgressData, error) {
	if req.UserID == "" {
		return nil, errors.New("شناسه کاربر الزامی است")
	}

	// Check if entry already exists
	existing, _ := s.dayProgressRepo.GetByUserWeekAndDay(ctx, req.UserID, req.WeekNumber, req.DayNumber)
	if existing != nil {
		return s.toDayProgressResponse(existing), nil
	}

	entry := &models.DayProgress{
		UserID:     req.UserID,
		WeekNumber: req.WeekNumber,
		DayNumber:  req.DayNumber,
	}

	if err := s.dayProgressRepo.Create(ctx, entry); err != nil {
		return nil, fmt.Errorf("خطا در ایجاد پیشرفت روز: %w", err)
	}

	return s.toDayProgressResponse(entry), nil
}

func (s *DayProgressService) GetDayProgressById(ctx context.Context, id string) (*schemas.DayProgressData, error) {
	entry, err := s.dayProgressRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("پیشرفت روز مورد نظر یافت نشد")
		}
		return nil, fmt.Errorf("خطا در دریافت پیشرفت روز: %w", err)
	}

	return s.toDayProgressResponse(entry), nil
}

func (s *DayProgressService) GetAllDayProgress(ctx context.Context, req *schemas.DayProgressListRequest) (*schemas.DayProgressListResponse, error) {
	filterFunc := s.buildFilters(req)

	entries, total, err := s.dayProgressRepo.List(ctx, req.Page, req.PageSize, filterFunc)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت پیشرفت روزها: %w", err)
	}

	responses := make([]schemas.DayProgressData, len(entries))
	for i, entry := range entries {
		responses[i] = *s.toDayProgressResponse(&entry)
	}

	pages := int((total + int64(req.PageSize) - 1) / int64(req.PageSize))
	if pages == 0 {
		pages = 1
	}

	return &schemas.DayProgressListResponse{
		PaginatedResponse: schemas.PaginatedResponse[schemas.DayProgressData]{
			Data:     responses,
			Total:    total,
			Page:     req.Page,
			PageSize: req.PageSize,
			Pages:    pages,
		},
	}, nil
}

func (s *DayProgressService) UpdateDayProgress(ctx context.Context, id string, req *schemas.DayProgressUpdateRequest) (*schemas.DayProgressData, error) {
	entry, err := s.dayProgressRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("پیشرفت روز مورد نظر یافت نشد")
		}
		return nil, fmt.Errorf("خطا در دریافت پیشرفت روز: %w", err)
	}

	if req.IsCompleted != nil {
		entry.IsCompleted = *req.IsCompleted
		if *req.IsCompleted && entry.CompletedAt == nil {
			now := time.Now()
			entry.CompletedAt = &now
		}
	}

	if req.CompletedAt != nil {
		entry.CompletedAt = req.CompletedAt
	}

	if err := s.dayProgressRepo.Update(ctx, entry); err != nil {
		return nil, fmt.Errorf("خطا در بروزرسانی پیشرفت روز: %w", err)
	}

	return s.toDayProgressResponse(entry), nil
}

func (s *DayProgressService) DeleteDayProgress(ctx context.Context, id string) error {
	_, err := s.dayProgressRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("پیشرفت روز مورد نظر یافت نشد")
		}
		return fmt.Errorf("خطا در دریافت پیشرفت روز: %w", err)
	}

	if err := s.dayProgressRepo.Delete(ctx, id); err != nil {
		return fmt.Errorf("خطا در حذف پیشرفت روز: %w", err)
	}

	return nil
}

func (s *DayProgressService) GetSummary(ctx context.Context, userID string, weekNumber int) (*schemas.DayProgressSummaryResponse, error) {
	entries, err := s.dayProgressRepo.GetByUserAndWeek(ctx, userID, weekNumber)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت خلاصه پیشرفت: %w", err)
	}

	days := make([]schemas.DayProgressSummaryItem, 7)
	for i := 0; i < 7; i++ {
		days[i] = schemas.DayProgressSummaryItem{
			DayNumber: i + 1,
		}
	}

	for _, entry := range entries {
		if entry.DayNumber >= 1 && entry.DayNumber <= 7 {
			idx := entry.DayNumber - 1
			days[idx].IsCompleted = entry.IsCompleted
			days[idx].CompletedAt = entry.CompletedAt
			openedAt := entry.OpenedAt
			days[idx].OpenedAt = &openedAt
		}
	}

	return &schemas.DayProgressSummaryResponse{
		WeekNumber: weekNumber,
		Days:       days,
	}, nil
}

func (s *DayProgressService) MarkDayCompleted(ctx context.Context, userID string, weekNumber, dayNumber int) (*schemas.DayProgressData, error) {
	// Ensure the entry exists
	existing, _ := s.dayProgressRepo.GetByUserWeekAndDay(ctx, userID, weekNumber, dayNumber)
	if existing == nil {
		entry := &models.DayProgress{
			UserID:      userID,
			WeekNumber:  weekNumber,
			DayNumber:   dayNumber,
			IsCompleted: true,
		}
		now := time.Now()
		entry.CompletedAt = &now
		if err := s.dayProgressRepo.Create(ctx, entry); err != nil {
			return nil, fmt.Errorf("خطا در ثبت تکمیل روز: %w", err)
		}
		return s.toDayProgressResponse(entry), nil
	}

	if err := s.dayProgressRepo.MarkCompleted(ctx, userID, weekNumber, dayNumber); err != nil {
		return nil, fmt.Errorf("خطا در ثبت تکمیل روز: %w", err)
	}

	updated, err := s.dayProgressRepo.GetByUserWeekAndDay(ctx, userID, weekNumber, dayNumber)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت پیشرفت روز: %w", err)
	}

	return s.toDayProgressResponse(updated), nil
}

func (s *DayProgressService) buildFilters(req *schemas.DayProgressListRequest) func(*gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		db = repository.ApplyDateRangeFilter(db, req.DateFrom, req.DateTo)

		if req.UserID != "" {
			db = db.Where("user_id = ?", req.UserID)
		}
		if req.WeekNumber != nil {
			db = db.Where("week_number = ?", *req.WeekNumber)
		}
		if req.DayNumber != nil {
			db = db.Where("day_number = ?", *req.DayNumber)
		}
		if req.IsCompleted != nil {
			db = db.Where("is_completed = ?", *req.IsCompleted)
		}

		if req.SortBy != "" {
			db = repository.ApplySorting(db, req.SortBy, req.SortOrder)
		} else {
			db = db.Order("day_number asc")
		}

		return db
	}
}

func (s *DayProgressService) toDayProgressResponse(entry *models.DayProgress) *schemas.DayProgressData {
	return &schemas.DayProgressData{
		ID:          entry.ID.String(),
		UserID:      entry.UserID,
		WeekNumber:  entry.WeekNumber,
		DayNumber:   entry.DayNumber,
		OpenedAt:    entry.OpenedAt,
		IsCompleted: entry.IsCompleted,
		CompletedAt: entry.CompletedAt,
		CreatedAt:   entry.CreatedAt,
		UpdatedAt:   entry.UpdatedAt,
	}
}
