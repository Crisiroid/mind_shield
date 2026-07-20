package handler

import (
	"net/http"

	"psychology-backend/internal/interfaces"
	"psychology-backend/pkg/response"
	"psychology-backend/pkg/schemas"

	"github.com/labstack/echo/v4"
)

type UserMediaProgressHandler struct {
	*BaseHandler
	progressService interfaces.UserMediaProgressServiceInterface
}

func NewUserMediaProgressHandler(progressService interfaces.UserMediaProgressServiceInterface) *UserMediaProgressHandler {
	return &UserMediaProgressHandler{
		BaseHandler:     NewBaseHandler(),
		progressService: progressService,
	}
}

func (h *UserMediaProgressHandler) ListMyProgress(c echo.Context) error {
	userID := h.GetUserID(c)
	if userID == "" {
		return response.BadRequest(c, "شناسه کاربر الزامی است", "")
	}

	result, err := h.progressService.ListMyProgress(c.Request().Context(), userID)
	if err != nil {
		return h.InternalError(c, "خطا در دریافت پیشرفت", err)
	}

	return response.OK(c, "پیشرفت با موفقیت دریافت شد", result)
}

func (h *UserMediaProgressHandler) UpsertProgress(c echo.Context) error {
	userID := h.GetUserID(c)
	if userID == "" {
		return response.BadRequest(c, "شناسه کاربر الزامی است", "")
	}

	mediaID := c.Param("media_id")
	if mediaID == "" {
		return response.BadRequest(c, "شناسه محتوا الزامی است", "")
	}

	var req schemas.UserMediaProgressUpsertRequest
	if err := h.BindAndValidate(c, &req); err != nil {
		return err
	}

	result, err := h.progressService.UpsertProgress(c.Request().Context(), userID, mediaID, &req)
	if err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در ثبت پیشرفت", err.Error())
	}

	return response.OK(c, "پیشرفت با موفقیت ثبت شد", result)
}
