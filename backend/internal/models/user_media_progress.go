package models

import (
	"time"

	"github.com/google/uuid"
)

// UserMediaProgress tracks, per user, whether a piece of weekly media content
// has been watched/listened to and how far the user got. The composite unique
// index on (user_id, media_content_id) guarantees a single progress row per
// user per content item so upserts stay idempotent.
type UserMediaProgress struct {
	BaseModel
	UserID          uuid.UUID  `gorm:"type:uuid;not null;uniqueIndex:idx_user_media_progress" json:"user_id"`
	MediaContentID  uuid.UUID  `gorm:"type:uuid;not null;uniqueIndex:idx_user_media_progress" json:"media_content_id"`
	Status          string     `gorm:"size:20;not null;default:'not_started'" json:"status"`
	ProgressSeconds int        `gorm:"default:0" json:"progress_seconds"`
	CompletedAt     *time.Time `json:"completed_at,omitempty"`
}

func (UserMediaProgress) TableName() string {
	return "user_media_progress"
}
