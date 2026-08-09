package handler

import (
	"net/http"
	"strconv"

	"psychology-backend/internal/interfaces"
	"psychology-backend/pkg/response"
	"psychology-backend/pkg/schemas"

	"github.com/labstack/echo/v4"
)

type WeeklyExerciseHandler struct {
	*BaseHandler
	weeklyExerciseService interfaces.WeeklyExerciseServiceInterface
}

func NewWeeklyExerciseHandler(service interfaces.WeeklyExerciseServiceInterface) *WeeklyExerciseHandler {
	return &WeeklyExerciseHandler{
		BaseHandler:           NewBaseHandler(),
		weeklyExerciseService: service,
	}
}

func (h *WeeklyExerciseHandler) CreateWeeklyExerciseResponse(c echo.Context) error {
	var req schemas.WeeklyExerciseResponseCreateRequest
	if err := h.BindAndValidate(c, &req); err != nil {
		return err
	}

	req.UserID = h.GetUserID(c)

	entry, err := h.weeklyExerciseService.CreateWeeklyExerciseResponse(c.Request().Context(), &req)
	if err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در ثبت پاسخ تمرین", err.Error())
	}

	return response.Created(c, "پاسخ تمرین با موفقیت ثبت شد", entry)
}

func (h *WeeklyExerciseHandler) GetWeeklyExerciseResponseByID(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return response.BadRequest(c, "شناسه پاسخ تمرین الزامی است", "")
	}

	entry, err := h.weeklyExerciseService.GetWeeklyExerciseResponseById(c.Request().Context(), id)
	if err != nil {
		return h.NotFound(c, "پاسخ تمرین")
	}

	return response.OK(c, "پاسخ تمرین با موفقیت دریافت شد", entry)
}

func (h *WeeklyExerciseHandler) ListWeeklyExerciseResponses(c echo.Context) error {
	var req schemas.WeeklyExerciseResponseListRequest
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

	entries, err := h.weeklyExerciseService.GetAllWeeklyExerciseResponses(c.Request().Context(), &req)
	if err != nil {
		return h.InternalError(c, "خطا در دریافت پاسخ‌های تمرین", err)
	}

	return response.OK(c, "پاسخ‌های تمرین با موفقیت دریافت شدند", entries)
}

func (h *WeeklyExerciseHandler) UpdateWeeklyExerciseResponse(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return response.BadRequest(c, "شناسه پاسخ تمرین الزامی است", "")
	}

	var req schemas.WeeklyExerciseResponseUpdateRequest
	if err := h.BindAndValidate(c, &req); err != nil {
		return err
	}

	entry, err := h.weeklyExerciseService.UpdateWeeklyExerciseResponse(c.Request().Context(), id, &req)
	if err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در بروزرسانی پاسخ تمرین", err.Error())
	}

	return response.OK(c, "پاسخ تمرین با موفقیت بروزرسانی شد", entry)
}

func (h *WeeklyExerciseHandler) DeleteWeeklyExerciseResponse(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return response.BadRequest(c, "شناسه پاسخ تمرین الزامی است", "")
	}

	if err := h.weeklyExerciseService.DeleteWeeklyExerciseResponse(c.Request().Context(), id); err != nil {
		return response.Error(c, http.StatusBadRequest, "خطا در حذف پاسخ تمرین", err.Error())
	}

	return response.OK(c, "پاسخ تمرین با موفقیت حذف شد", nil)
}

func (h *WeeklyExerciseHandler) GetByUserAndWeek(c echo.Context) error {
	userID := h.GetUserID(c)
	weekStr := c.Param("week_number")
	week, err := strconv.Atoi(weekStr)
	if err != nil {
		return response.BadRequest(c, "شماره هفته نامعتبر است", "")
	}

	entries, err := h.weeklyExerciseService.GetByUserAndWeek(c.Request().Context(), userID, week)
	if err != nil {
		return h.InternalError(c, "خطا در دریافت پاسخ‌های تمرین", err)
	}

	return response.OK(c, "پاسخ‌های تمرین با موفقیت دریافت شدند", entries)
}
