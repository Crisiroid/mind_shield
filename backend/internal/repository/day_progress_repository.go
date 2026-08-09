package repository

import (
	"context"
	"time"

	"psychology-backend/internal/models"

	"gorm.io/gorm"
)

type DayProgressRepository struct {
	*BaseRepository
}

func NewDayProgressRepository(db *gorm.DB) *DayProgressRepository {
	return &DayProgressRepository{
		BaseRepository: NewBaseRepository(db),
	}
}

func (r *DayProgressRepository) Create(ctx context.Context, entry *models.DayProgress) error {
	return r.BaseRepository.Create(ctx, entry)
}

func (r *DayProgressRepository) GetByID(ctx context.Context, id string) (*models.DayProgress, error) {
	var entry models.DayProgress
	err := r.BaseRepository.GetByID(ctx, &entry, id)
	if err != nil {
		return nil, err
	}
	return &entry, nil
}

func (r *DayProgressRepository) Update(ctx context.Context, entry *models.DayProgress) error {
	return r.BaseRepository.Update(ctx, entry)
}

func (r *DayProgressRepository) Delete(ctx context.Context, id string) error {
	return r.BaseRepository.Delete(ctx, &models.DayProgress{}, id)
}

func (r *DayProgressRepository) List(ctx context.Context, page, pageSize int, filters func(*gorm.DB) *gorm.DB) ([]models.DayProgress, int64, error) {
	var entries []models.DayProgress
	var total int64

	query := r.DB.WithContext(ctx).Model(&models.DayProgress{})

	if filters != nil {
		query = filters(query)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	if err := query.Offset(offset).Limit(pageSize).Order("day_number ASC").Find(&entries).Error; err != nil {
		return nil, 0, err
	}

	return entries, total, nil
}

func (r *DayProgressRepository) GetByUserAndWeek(ctx context.Context, userID string, weekNumber int) ([]models.DayProgress, error) {
	var entries []models.DayProgress
	err := r.DB.WithContext(ctx).
		Where("user_id = ? AND week_number = ?", userID, weekNumber).
		Order("day_number ASC").
		Find(&entries).Error
	return entries, err
}

func (r *DayProgressRepository) GetByUserWeekAndDay(ctx context.Context, userID string, weekNumber, dayNumber int) (*models.DayProgress, error) {
	var entry models.DayProgress
	err := r.DB.WithContext(ctx).
		Where("user_id = ? AND week_number = ? AND day_number = ?", userID, weekNumber, dayNumber).
		First(&entry).Error
	if err != nil {
		return nil, err
	}
	return &entry, nil
}

func (r *DayProgressRepository) MarkCompleted(ctx context.Context, userID string, weekNumber, dayNumber int) error {
	now := time.Now()
	return r.DB.WithContext(ctx).
		Model(&models.DayProgress{}).
		Where("user_id = ? AND week_number = ? AND day_number = ?", userID, weekNumber, dayNumber).
		Updates(map[string]interface{}{
			"is_completed": true,
			"completed_at": now,
		}).Error
}
