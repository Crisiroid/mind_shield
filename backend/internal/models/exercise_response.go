package models

import "time"

// ExerciseResponse is the generic weekly-program exercise answer store
// (Week 1 spec, section 4): one row per submitted exercise, with the raw
// answer payload kept as JSON so every exercise type (goal, daily_stress,
// quizzes, five-part records, weekly review/evaluation, ...) shares one table.
type ExerciseResponse struct {
	BaseModel
	UserID       string     `gorm:"type:uuid;not null;index:idx_exercise_responses_user_week_day" json:"user_id"`
	WeekNumber   int        `gorm:"not null;index:idx_exercise_responses_user_week_day;check:week_number BETWEEN 1 AND 8" json:"week_number"`
	DayNumber    int        `gorm:"not null;index:idx_exercise_responses_user_week_day;check:day_number BETWEEN 1 AND 56" json:"day_number"`
	ExerciseType string     `gorm:"type:varchar(50);not null" json:"exercise_type"`
	ResponseJSON string     `gorm:"type:jsonb;not null;default:'{}'" json:"response_json"`
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
}

func (ExerciseResponse) TableName() string {
	return "exercise_responses"
}
