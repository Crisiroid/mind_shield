package models

import "time"

type WeeklyExerciseResponse struct {
	BaseModel
	UserID       string     `gorm:"type:uuid;not null" json:"user_id"`
	WeekNumber   int        `gorm:"not null" json:"week_number"`
	DayNumber    int        `gorm:"not null" json:"day_number"`
	ExerciseType string     `gorm:"type:varchar(50);not null" json:"exercise_type"`
	ResponseData string     `gorm:"type:jsonb;not null;default:'{}'" json:"response_data"`
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
}

func (WeeklyExerciseResponse) TableName() string {
	return "weekly_exercise_responses"
}

type DayProgress struct {
	BaseModel
	UserID      string     `gorm:"type:uuid;not null" json:"user_id"`
	WeekNumber  int        `gorm:"not null" json:"week_number"`
	DayNumber   int        `gorm:"not null" json:"day_number"`
	OpenedAt    time.Time  `gorm:"autoCreateTime" json:"opened_at"`
	IsCompleted bool       `gorm:"default:false" json:"is_completed"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
}

func (DayProgress) TableName() string {
	return "day_progress"
}
