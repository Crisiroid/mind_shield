package repository

import (
	"context"

	"psychology-backend/internal/models"

	"gorm.io/gorm"
)

type WeeklyExerciseRepository struct {
	*BaseRepository
}

func NewWeeklyExerciseRepository(db *gorm.DB) *WeeklyExerciseRepository {
	return &WeeklyExerciseRepository{
		BaseRepository: NewBaseRepository(db),
	}
}

func (r *WeeklyExerciseRepository) Create(ctx context.Context, entry *models.WeeklyExerciseResponse) error {
	return r.BaseRepository.Create(ctx, entry)
}

func (r *WeeklyExerciseRepository) GetByID(ctx context.Context, id string) (*models.WeeklyExerciseResponse, error) {
	var entry models.WeeklyExerciseResponse
	err := r.BaseRepository.GetByID(ctx, &entry, id)
	if err != nil {
		return nil, err
	}
	return &entry, nil
}

func (r *WeeklyExerciseRepository) Update(ctx context.Context, entry *models.WeeklyExerciseResponse) error {
	return r.BaseRepository.Update(ctx, entry)
}

func (r *WeeklyExerciseRepository) Delete(ctx context.Context, id string) error {
	return r.BaseRepository.Delete(ctx, &models.WeeklyExerciseResponse{}, id)
}

func (r *WeeklyExerciseRepository) List(ctx context.Context, page, pageSize int, filters func(*gorm.DB) *gorm.DB) ([]models.WeeklyExerciseResponse, int64, error) {
	var entries []models.WeeklyExerciseResponse
	var total int64

	query := r.DB.WithContext(ctx).Model(&models.WeeklyExerciseResponse{})

	if filters != nil {
		query = filters(query)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	if err := query.Offset(offset).Limit(pageSize).Order("created_at desc").Find(&entries).Error; err != nil {
		return nil, 0, err
	}

	return entries, total, nil
}

func (r *WeeklyExerciseRepository) GetByUserAndWeek(ctx context.Context, userID string, weekNumber int) ([]models.WeeklyExerciseResponse, error) {
	var entries []models.WeeklyExerciseResponse
	err := r.DB.WithContext(ctx).
		Where("user_id = ? AND week_number = ?", userID, weekNumber).
		Order("day_number ASC, created_at ASC").
		Find(&entries).Error
	return entries, err
}

func (r *WeeklyExerciseRepository) GetByUserWeekAndDay(ctx context.Context, userID string, weekNumber, dayNumber int) ([]models.WeeklyExerciseResponse, error) {
	var entries []models.WeeklyExerciseResponse
	err := r.DB.WithContext(ctx).
		Where("user_id = ? AND week_number = ? AND day_number = ?", userID, weekNumber, dayNumber).
		Order("created_at ASC").
		Find(&entries).Error
	return entries, err
}
