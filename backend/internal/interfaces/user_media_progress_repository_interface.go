package interfaces

import (
	"context"

	"psychology-backend/internal/models"
)

type UserMediaProgressRepositoryInterface interface {
	Upsert(ctx context.Context, progress *models.UserMediaProgress) error
	ListByUser(ctx context.Context, userID string) ([]models.UserMediaProgress, error)
	GetByUserAndMedia(ctx context.Context, userID, mediaID string) (*models.UserMediaProgress, error)
}
