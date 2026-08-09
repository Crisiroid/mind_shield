package service

import (
	"context"
	"errors"
	"fmt"

	"psychology-backend/internal/interfaces"
	"psychology-backend/internal/models"
	"psychology-backend/internal/repository"
	"psychology-backend/pkg/schemas"

	"gorm.io/gorm"
)

type WeeklyExerciseService struct {
	weeklyExerciseRepo interfaces.WeeklyExerciseRepositoryInterface
}

func NewWeeklyExerciseService(repo interfaces.WeeklyExerciseRepositoryInterface) *WeeklyExerciseService {
	return &WeeklyExerciseService{
		weeklyExerciseRepo: repo,
	}
}

func (s *WeeklyExerciseService) CreateWeeklyExerciseResponse(ctx context.Context, req *schemas.WeeklyExerciseResponseCreateRequest) (*schemas.WeeklyExerciseResponseData, error) {
	if req.UserID == "" {
		return nil, errors.New("شناسه کاربر الزامی است")
	}

	entry := &models.WeeklyExerciseResponse{
		UserID:       req.UserID,
		WeekNumber:   req.WeekNumber,
		DayNumber:    req.DayNumber,
		ExerciseType: req.ExerciseType,
		ResponseData: req.ResponseData,
	}

	if err := s.weeklyExerciseRepo.Create(ctx, entry); err != nil {
		return nil, fmt.Errorf("خطا در ثبت پاسخ تمرین: %w", err)
	}

	return s.toResponse(entry), nil
}

func (s *WeeklyExerciseService) GetWeeklyExerciseResponseById(ctx context.Context, id string) (*schemas.WeeklyExerciseResponseData, error) {
	entry, err := s.weeklyExerciseRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("پاسخ تمرین مورد نظر یافت نشد")
		}
		return nil, fmt.Errorf("خطا در دریافت پاسخ تمرین: %w", err)
	}

	return s.toResponse(entry), nil
}

func (s *WeeklyExerciseService) GetAllWeeklyExerciseResponses(ctx context.Context, req *schemas.WeeklyExerciseResponseListRequest) (*schemas.WeeklyExerciseResponseListResponse, error) {
	filterFunc := s.buildFilters(req)

	entries, total, err := s.weeklyExerciseRepo.List(ctx, req.Page, req.PageSize, filterFunc)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت پاسخ‌های تمرین: %w", err)
	}

	responses := make([]schemas.WeeklyExerciseResponseData, len(entries))
	for i, entry := range entries {
		responses[i] = *s.toResponse(&entry)
	}

	pages := int((total + int64(req.PageSize) - 1) / int64(req.PageSize))
	if pages == 0 {
		pages = 1
	}

	return &schemas.WeeklyExerciseResponseListResponse{
		PaginatedResponse: schemas.PaginatedResponse[schemas.WeeklyExerciseResponseData]{
			Data:     responses,
			Total:    total,
			Page:     req.Page,
			PageSize: req.PageSize,
			Pages:    pages,
		},
	}, nil
}

func (s *WeeklyExerciseService) UpdateWeeklyExerciseResponse(ctx context.Context, id string, req *schemas.WeeklyExerciseResponseUpdateRequest) (*schemas.WeeklyExerciseResponseData, error) {
	entry, err := s.weeklyExerciseRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("پاسخ تمرین مورد نظر یافت نشد")
		}
		return nil, fmt.Errorf("خطا در دریافت پاسخ تمرین: %w", err)
	}

	if req.ResponseData != nil {
		entry.ResponseData = *req.ResponseData
	}

	if req.CompletedAt != nil {
		entry.CompletedAt = req.CompletedAt
	}

	if err := s.weeklyExerciseRepo.Update(ctx, entry); err != nil {
		return nil, fmt.Errorf("خطا در بروزرسانی پاسخ تمرین: %w", err)
	}

	return s.toResponse(entry), nil
}

func (s *WeeklyExerciseService) DeleteWeeklyExerciseResponse(ctx context.Context, id string) error {
	_, err := s.weeklyExerciseRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("پاسخ تمرین مورد نظر یافت نشد")
		}
		return fmt.Errorf("خطا در دریافت پاسخ تمرین: %w", err)
	}

	if err := s.weeklyExerciseRepo.Delete(ctx, id); err != nil {
		return fmt.Errorf("خطا در حذف پاسخ تمرین: %w", err)
	}

	return nil
}

func (s *WeeklyExerciseService) GetByUserAndWeek(ctx context.Context, userID string, weekNumber int) ([]schemas.WeeklyExerciseResponseData, error) {
	entries, err := s.weeklyExerciseRepo.GetByUserAndWeek(ctx, userID, weekNumber)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت پاسخ‌های تمرین: %w", err)
	}

	responses := make([]schemas.WeeklyExerciseResponseData, len(entries))
	for i, entry := range entries {
		responses[i] = *s.toResponse(&entry)
	}

	return responses, nil
}

func (s *WeeklyExerciseService) buildFilters(req *schemas.WeeklyExerciseResponseListRequest) func(*gorm.DB) *gorm.DB {
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
		if req.ExerciseType != nil {
			db = db.Where("exercise_type = ?", *req.ExerciseType)
		}

		if req.SortBy != "" {
			db = repository.ApplySorting(db, req.SortBy, req.SortOrder)
		} else {
			db = db.Order("created_at desc")
		}

		return db
	}
}

func (s *WeeklyExerciseService) toResponse(entry *models.WeeklyExerciseResponse) *schemas.WeeklyExerciseResponseData {
	return &schemas.WeeklyExerciseResponseData{
		ID:           entry.ID.String(),
		UserID:       entry.UserID,
		WeekNumber:   entry.WeekNumber,
		DayNumber:    entry.DayNumber,
		ExerciseType: entry.ExerciseType,
		ResponseData: entry.ResponseData,
		CompletedAt:  entry.CompletedAt,
		CreatedAt:    entry.CreatedAt,
		UpdatedAt:    entry.UpdatedAt,
	}
}
