package handler

import (
	"net/http"
	"strconv"

	"psychology-backend/internal/interfaces"
	"psychology-backend/pkg/response"
	"psychology-backend/pkg/schemas"

	"github.com/labstack/echo/v4"
)

type DayProgressHandler struct {
	*BaseHandler
	dayProgressService interfaces.DayProgressServiceInterface
}

func NewDayProgressHandler(service interfaces.DayProgressServiceInterface) *DayProgressHandler {
	return &DayProgressHandler{
		BaseHandler:        NewBaseHandler(),
		dayProgressService: service,
	}
}

func (h *DayProgressHandler) CreateDayProgress(c echo.Context) error {
	var req schemas.DayProgressCreateRequest
	if err := h.BindAndValidate(c, &req); err != nil {
		return err
	}

	req.UserID = h.GetUserID(c)

	entry, err := h.dayProgressService.CreateDayProgress(c.Request().Context(), &req)
	if err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در ایجاد پیشرفت روز", err.Error())
	}

	return response.Created(c, "پیشرفت روز با موفقیت ایجاد شد", entry)
}

func (h *DayProgressHandler) GetDayProgressByID(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return response.BadRequest(c, "شناسه پیشرفت روز الزامی است", "")
	}

	entry, err := h.dayProgressService.GetDayProgressById(c.Request().Context(), id)
	if err != nil {
		return h.NotFound(c, "پیشرفت روز")
	}

	return response.OK(c, "پیشرفت روز با موفقیت دریافت شد", entry)
}

func (h *DayProgressHandler) ListDayProgress(c echo.Context) error {
	var req schemas.DayProgressListRequest
	if err := c.Bind(&req); err != nil {
		return response.BadRequest(c, "بدنه درخواست نامعتبر است", "")
	}

	if req.Page <= 0 {
		req.Page = 1
	}
	if req.PageSize <= 0 {
		req.PageSize = 20
	}

	if h.GetUserRole(c) == "user" {
		req.UserID = h.GetUserID(c)
	}

	entries, err := h.dayProgressService.GetAllDayProgress(c.Request().Context(), &req)
	if err != nil {
		return h.InternalError(c, "خطا در دریافت پیشرفت روزها", err)
	}

	return response.OK(c, "پیشرفت روزها با موفقیت دریافت شدند", entries)
}

func (h *DayProgressHandler) UpdateDayProgress(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return response.BadRequest(c, "شناسه پیشرفت روز الزامی است", "")
	}

	var req schemas.DayProgressUpdateRequest
	if err := h.BindAndValidate(c, &req); err != nil {
		return err
	}

	entry, err := h.dayProgressService.UpdateDayProgress(c.Request().Context(), id, &req)
	if err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در بروزرسانی پیشرفت روز", err.Error())
	}

	return response.OK(c, "پیشرفت روز با موفقیت بروزرسانی شد", entry)
}

func (h *DayProgressHandler) DeleteDayProgress(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return response.BadRequest(c, "شناسه پیشرفت روز الزامی است", "")
	}

	if err := h.dayProgressService.DeleteDayProgress(c.Request().Context(), id); err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در حذف پیشرفت روز", err.Error())
	}

	return response.OK(c, "پیشرفت روز با موفقیت حذف شد", nil)
}

func (h *DayProgressHandler) GetSummary(c echo.Context) error {
	userID := h.GetUserID(c)
	weekStr := c.QueryParam("week_number")
	week, err := strconv.Atoi(weekStr)
	if err != nil {
		week = 1
	}

	summary, err := h.dayProgressService.GetSummary(c.Request().Context(), userID, week)
	if err != nil {
		return h.InternalError(c, "خطا در دریافت خلاصه پیشرفت", err)
	}

	return response.OK(c, "خلاصه پیشرفت با موفقیت دریافت شد", summary)
}

func (h *DayProgressHandler) MarkDayCompleted(c echo.Context) error {
	userID := h.GetUserID(c)

	var req struct {
		WeekNumber int `json:"week_number" validate:"required,min=1,max=8"`
		DayNumber  int `json:"day_number" validate:"required,min=1,max=56"`
	}
	if err := h.BindAndValidate(c, &req); err != nil {
		return err
	}

	entry, err := h.dayProgressService.MarkDayCompleted(c.Request().Context(), userID, req.WeekNumber, req.DayNumber)
	if err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در ثبت تکمیل روز", err.Error())
	}

	return response.OK(c, "روز با موفقیت تکمیل شد", entry)
}
