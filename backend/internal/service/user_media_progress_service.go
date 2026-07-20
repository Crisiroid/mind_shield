package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"psychology-backend/internal/interfaces"
	"psychology-backend/internal/models"
	"psychology-backend/pkg/schemas"

	"github.com/google/uuid"
)

type UserMediaProgressService struct {
	progressRepo interfaces.UserMediaProgressRepositoryInterface
}

func NewUserMediaProgressService(progressRepo interfaces.UserMediaProgressRepositoryInterface) *UserMediaProgressService {
	return &UserMediaProgressService{
		progressRepo: progressRepo,
	}
}

func (s *UserMediaProgressService) ListMyProgress(ctx context.Context, userID string) (*schemas.UserMediaProgressListResponse, error) {
	list, err := s.progressRepo.ListByUser(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت پیشرفت: %w", err)
	}

	responses := make([]schemas.UserMediaProgressResponse, len(list))
	for i := range list {
		responses[i] = *s.toResponse(&list[i])
	}

	total := int64(len(responses))
	return &schemas.UserMediaProgressListResponse{
		PaginatedResponse: schemas.PaginatedResponse[schemas.UserMediaProgressResponse]{
			Data:     responses,
			Total:    total,
			Page:     1,
			PageSize: len(responses),
			Pages:    1,
		},
	}, nil
}

func (s *UserMediaProgressService) UpsertProgress(ctx context.Context, userID, mediaID string, req *schemas.UserMediaProgressUpsertRequest) (*schemas.UserMediaProgressResponse, error) {
	uid, err := uuid.Parse(userID)
	if err != nil {
		return nil, errors.New("شناسه کاربر نامعتبر است")
	}
	mid, err := uuid.Parse(mediaID)
	if err != nil {
		return nil, errors.New("شناسه محتوا نامعتبر است")
	}

	existing, err := s.progressRepo.GetByUserAndMedia(ctx, userID, mediaID)
	if err != nil {
		return nil, fmt.Errorf("خطا در دریافت پیشرفت: %w", err)
	}

	progress := &models.UserMediaProgress{
		UserID:          uid,
		MediaContentID:  mid,
		Status:          req.Status,
		ProgressSeconds: req.ProgressSeconds,
	}

	if existing != nil {
		progress.ID = existing.ID
		progress.CreatedAt = existing.CreatedAt
		progress.CompletedAt = existing.CompletedAt
	}

	// Stamp completion time once when the item first becomes completed.
	if req.Status == "completed" && progress.CompletedAt == nil {
		now := time.Now()
		progress.CompletedAt = &now
	}

	if err := s.progressRepo.Upsert(ctx, progress); err != nil {
		return nil, fmt.Errorf("خطا در ثبت پیشرفت: %w", err)
	}

	return s.toResponse(progress), nil
}

func (s *UserMediaProgressService) toResponse(p *models.UserMediaProgress) *schemas.UserMediaProgressResponse {
	var completedAt *string
	if p.CompletedAt != nil {
		formatted := p.CompletedAt.Format(time.RFC3339)
		completedAt = &formatted
	}

	return &schemas.UserMediaProgressResponse{
		ID:              p.ID.String(),
		MediaContentID:  p.MediaContentID.String(),
		Status:          p.Status,
		ProgressSeconds: p.ProgressSeconds,
		CompletedAt:     completedAt,
		CreatedAt:       p.CreatedAt.Format(time.RFC3339),
		UpdatedAt:       p.UpdatedAt.Format(time.RFC3339),
	}
}
