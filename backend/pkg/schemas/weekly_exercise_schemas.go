package schemas

import "time"

// --- WeeklyExerciseResponse ---

type WeeklyExerciseResponseCreateRequest struct {
	UserID       string `json:"user_id"`
	WeekNumber   int    `json:"week_number" validate:"required,min=1,max=8"`
	DayNumber    int    `json:"day_number" validate:"required,min=1,max=56"`
	ExerciseType string `json:"exercise_type" validate:"required"`
	ResponseData string `json:"response_data" validate:"required"`
}

type WeeklyExerciseResponseUpdateRequest struct {
	ResponseData *string    `json:"response_data,omitempty"`
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
}

type WeeklyExerciseResponseData struct {
	ID           string     `json:"id"`
	UserID       string     `json:"user_id"`
	WeekNumber   int        `json:"week_number"`
	DayNumber    int        `json:"day_number"`
	ExerciseType string     `json:"exercise_type"`
	ResponseData string     `json:"response_data"`
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

type WeeklyExerciseResponseListRequest struct {
	PaginatedRequest
	FilterRequest
	WeekNumber   *int    `query:"week_number" form:"week_number"`
	DayNumber    *int    `query:"day_number" form:"day_number"`
	ExerciseType *string `query:"exercise_type" form:"exercise_type"`
}

type WeeklyExerciseResponseListResponse struct {
	PaginatedResponse[WeeklyExerciseResponseData]
}

// --- DayProgress ---

type DayProgressCreateRequest struct {
	UserID     string `json:"user_id"`
	WeekNumber int    `json:"week_number" validate:"required,min=1,max=8"`
	DayNumber  int    `json:"day_number" validate:"required,min=1,max=56"`
}

type DayProgressUpdateRequest struct {
	IsCompleted *bool      `json:"is_completed,omitempty"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
}

type DayProgressData struct {
	ID          string     `json:"id"`
	UserID      string     `json:"user_id"`
	WeekNumber  int        `json:"week_number"`
	DayNumber   int        `json:"day_number"`
	OpenedAt    time.Time  `json:"opened_at"`
	IsCompleted bool       `json:"is_completed"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

type DayProgressListRequest struct {
	PaginatedRequest
	FilterRequest
	WeekNumber  *int  `query:"week_number" form:"week_number"`
	DayNumber   *int  `query:"day_number" form:"day_number"`
	IsCompleted *bool `query:"is_completed" form:"is_completed"`
}

type DayProgressListResponse struct {
	PaginatedResponse[DayProgressData]
}

// --- DayProgress Summary (for home screen) ---

type DayProgressSummaryItem struct {
	DayNumber   int        `json:"day_number"`
	IsCompleted bool       `json:"is_completed"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
	OpenedAt    *time.Time `json:"opened_at,omitempty"`
}

type DayProgressSummaryResponse struct {
	WeekNumber int                      `json:"week_number"`
	Days       []DayProgressSummaryItem `json:"days"`
}
