package database

import (
	"fmt"
	"log"
	"psychology-backend/internal/models"

	"gorm.io/gorm"
)

// CustomSchemas lists the non-default PostgreSQL schemas used by fully qualified table names
var CustomSchemas = []string{"admin_panel"}

// EnsureCustomSchemas creates every non-default schema referenced by the models so that
// AutoMigrate can create their tables on a fresh database
func EnsureCustomSchemas(db *gorm.DB) error {
	for _, schema := range CustomSchemas {
		if err := db.Exec(fmt.Sprintf("CREATE SCHEMA IF NOT EXISTS %s", schema)).Error; err != nil {
			return fmt.Errorf("failed to create schema %q: %w", schema, err)
		}
		log.Printf("Schema %q ensured", schema)
	}
	return nil
}

// AutoMigrate creates and updates every application table, including the non-default schemas
func AutoMigrate(db *gorm.DB) error {
	log.Println("Running database migrations...")

	if err := EnsureCustomSchemas(db); err != nil {
		return err
	}

	err := db.AutoMigrate(
		&models.User{},
		&models.DailyCalendar{},

		&models.EmotionTriangleInteraction{},
		&models.StressEvent{},
		&models.BodyTensionMap{},

		&models.BreathingSession{},
		&models.CognitiveErrorGame{},
		&models.MentalMust{},
		&models.NegativeThought{},
		&models.MindCourtEvidence{},
		&models.ConflictExercise{},
		&models.MoodTracker{},
		&models.RoleAndValue{},
		&models.SkyThought{},

		&models.MindfulTimer{},
		&models.AcceptanceExercise{},
		&models.WeeklyReport{},

		&models.WeeklyExerciseResponse{},
		&models.DayProgress{},

		&models.WeeklyMediaContent{},
		&models.UserMediaProgress{},

		&models.AdminUser{},
		&models.AdminRole{},
		&models.UserReport{},
		&models.SystemLog{},
	)

	if err != nil {
		return err
	}

	log.Println("Database migrations completed successfully")
	return nil
}
