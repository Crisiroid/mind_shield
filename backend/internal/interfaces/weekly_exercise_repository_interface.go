package interfaces

import (
	"context"

	"psychology-backend/internal/models"

	"gorm.io/gorm"
)

type WeeklyExerciseRepositoryInterface interface {
	Create(ctx context.Context, entry *models.WeeklyExerciseResponse) error
	GetByID(ctx context.Context, id string) (*models.WeeklyExerciseResponse, error)
	Update(ctx context.Context, entry *models.WeeklyExerciseResponse) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, page, pageSize int, filters func(*gorm.DB) *gorm.DB) ([]models.WeeklyExerciseResponse, int64, error)
	GetByUserAndWeek(ctx context.Context, userID string, weekNumber int) ([]models.WeeklyExerciseResponse, error)
	GetByUserWeekAndDay(ctx context.Context, userID string, weekNumber, dayNumber int) ([]models.WeeklyExerciseResponse, error)
}
