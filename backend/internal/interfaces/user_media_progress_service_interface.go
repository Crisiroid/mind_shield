package interfaces

import (
	"context"

	"psychology-backend/pkg/schemas"
)

type UserMediaProgressServiceInterface interface {
	ListMyProgress(ctx context.Context, userID string) (*schemas.UserMediaProgressListResponse, error)
	UpsertProgress(ctx context.Context, userID, mediaID string, req *schemas.UserMediaProgressUpsertRequest) (*schemas.UserMediaProgressResponse, error)
}
