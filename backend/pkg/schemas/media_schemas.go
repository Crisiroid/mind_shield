package schemas

type (
	WeeklyMediaContentCreateRequest struct {
		WeekNumber  int    `json:"week_number" validate:"required,min=1,max=52"`
		FileType    string `json:"file_type" validate:"required,oneof=audio video document image"`
		Description string `json:"description"`
	}

	WeeklyMediaContentUpdateRequest struct {
		WeekNumber  int    `json:"week_number" validate:"min=1,max=52"`
		FileType    string `json:"file_type" validate:"omitempty,oneof=audio video document image"`
		Description string `json:"description"`
		IsActive    *bool  `json:"is_active"`
	}

	WeeklyMediaContentListRequest struct {
		PaginatedRequest
		WeekNumber *int   `json:"week_number" query:"week_number" form:"week_number"`
		FileType   string `json:"file_type" query:"file_type" form:"file_type"`
		IsActive   *bool  `json:"is_active" query:"is_active" form:"is_active"`
	}

	WeeklyMediaContentResponse struct {
		ID            string `json:"id"`
		FileName      string `json:"file_name"`
		FileType      string `json:"file_type"`
		FileSize      int64  `json:"file_size"`
		FileURL       string `json:"file_url"`
		WeekNumber    int    `json:"week_number"`
		Description   string `json:"description,omitempty"`
		ContentType   string `json:"content_type"`
		OriginalName  string `json:"original_name"`
		StoragePath   string `json:"storage_path"`
		IsActive      bool   `json:"is_active"`
		DownloadCount int    `json:"download_count"`
		CreatedAt     string `json:"created_at"`
		UpdatedAt     string `json:"updated_at"`
	}

	WeeklyMediaContentListResponse struct {
		PaginatedResponse[WeeklyMediaContentResponse]
	}

	UserMediaProgressUpsertRequest struct {
		Status          string `json:"status" validate:"required,oneof=not_started in_progress completed"`
		ProgressSeconds int    `json:"progress_seconds" validate:"min=0"`
	}

	UserMediaProgressResponse struct {
		ID              string  `json:"id"`
		MediaContentID  string  `json:"media_content_id"`
		Status          string  `json:"status"`
		ProgressSeconds int     `json:"progress_seconds"`
		CompletedAt     *string `json:"completed_at,omitempty"`
		CreatedAt       string  `json:"created_at"`
		UpdatedAt       string  `json:"updated_at"`
	}

	UserMediaProgressListResponse struct {
		PaginatedResponse[UserMediaProgressResponse]
	}
)
