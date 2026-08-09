package interfaces

import (
	"context"

	"psychology-backend/pkg/schemas"
)

type DayProgressServiceInterface interface {
	CreateDayProgress(ctx context.Context, req *schemas.DayProgressCreateRequest) (*schemas.DayProgressData, error)
	GetDayProgressById(ctx context.Context, id string) (*schemas.DayProgressData, error)
	GetAllDayProgress(ctx context.Context, req *schemas.DayProgressListRequest) (*schemas.DayProgressListResponse, error)
	UpdateDayProgress(ctx context.Context, id string, req *schemas.DayProgressUpdateRequest) (*schemas.DayProgressData, error)
	DeleteDayProgress(ctx context.Context, id string) error
	GetSummary(ctx context.Context, userID string, weekNumber int) (*schemas.DayProgressSummaryResponse, error)
	MarkDayCompleted(ctx context.Context, userID string, weekNumber, dayNumber int) (*schemas.DayProgressData, error)
}
