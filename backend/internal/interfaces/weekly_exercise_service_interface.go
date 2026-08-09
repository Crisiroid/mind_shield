package interfaces

import (
	"context"

	"psychology-backend/pkg/schemas"
)

type WeeklyExerciseServiceInterface interface {
	CreateWeeklyExerciseResponse(ctx context.Context, req *schemas.WeeklyExerciseResponseCreateRequest) (*schemas.WeeklyExerciseResponseData, error)
	GetWeeklyExerciseResponseById(ctx context.Context, id string) (*schemas.WeeklyExerciseResponseData, error)
	GetAllWeeklyExerciseResponses(ctx context.Context, req *schemas.WeeklyExerciseResponseListRequest) (*schemas.WeeklyExerciseResponseListResponse, error)
	UpdateWeeklyExerciseResponse(ctx context.Context, id string, req *schemas.WeeklyExerciseResponseUpdateRequest) (*schemas.WeeklyExerciseResponseData, error)
	DeleteWeeklyExerciseResponse(ctx context.Context, id string) error
	GetByUserAndWeek(ctx context.Context, userID string, weekNumber int) ([]schemas.WeeklyExerciseResponseData, error)
}
