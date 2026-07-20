package repository

import (
	"context"
	"errors"

	"psychology-backend/internal/models"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type UserMediaProgressRepository struct {
	*BaseRepository
}

func NewUserMediaProgressRepository(db *gorm.DB) *UserMediaProgressRepository {
	return &UserMediaProgressRepository{
		BaseRepository: NewBaseRepository(db),
	}
}

// Upsert inserts a new progress row or, when one already exists for the
// (user_id, media_content_id) pair, updates the tracked fields in place.
func (r *UserMediaProgressRepository) Upsert(ctx context.Context, progress *models.UserMediaProgress) error {
	return r.DB.WithContext(ctx).Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "user_id"}, {Name: "media_content_id"}},
		DoUpdates: clause.AssignmentColumns([]string{
			"status",
			"progress_seconds",
			"completed_at",
			"updated_at",
		}),
	}).Create(progress).Error
}

func (r *UserMediaProgressRepository) ListByUser(ctx context.Context, userID string) ([]models.UserMediaProgress, error) {
	var list []models.UserMediaProgress
	err := r.DB.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("updated_at desc").
		Find(&list).Error
	if err != nil {
		return nil, err
	}
	return list, nil
}

func (r *UserMediaProgressRepository) GetByUserAndMedia(ctx context.Context, userID, mediaID string) (*models.UserMediaProgress, error) {
	var progress models.UserMediaProgress
	err := r.DB.WithContext(ctx).
		Where("user_id = ? AND media_content_id = ?", userID, mediaID).
		First(&progress).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &progress, nil
}
