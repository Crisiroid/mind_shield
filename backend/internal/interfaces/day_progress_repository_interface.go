package interfaces

import (
	"context"

	"psychology-backend/internal/models"

	"gorm.io/gorm"
)

type DayProgressRepositoryInterface interface {
	Create(ctx context.Context, entry *models.DayProgress) error
	GetByID(ctx context.Context, id string) (*models.DayProgress, error)
	Update(ctx context.Context, entry *models.DayProgress) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, page, pageSize int, filters func(*gorm.DB) *gorm.DB) ([]models.DayProgress, int64, error)
	GetByUserAndWeek(ctx context.Context, userID string, weekNumber int) ([]models.DayProgress, error)
	GetByUserWeekAndDay(ctx context.Context, userID string, weekNumber, dayNumber int) (*models.DayProgress, error)
	MarkCompleted(ctx context.Context, userID string, weekNumber, dayNumber int) error
}
