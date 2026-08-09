import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as repo from "./notifications.repository.js";
const router = Router();
router.get("/", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        const notifications = await repo.getUserNotifications(userId);
        res.status(200).json({ success: true, data: notifications });
    }
    catch (err) {
        next(err);
    }
});
router.get("/unread-count", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        const data = await repo.getUnreadCount(userId);
        res.status(200).json({ success: true, data });
    }
    catch (err) {
        next(err);
    }
});
router.patch("/read-all", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        await repo.markAllAsRead(userId);
        res.status(200).json({ success: true, message: "All notifications marked as read" });
    }
    catch (err) {
        next(err);
    }
});
router.patch("/:id/read", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        const id = req.params.id;
        await repo.markAsRead(id, userId);
        res.status(200).json({ success: true, message: "Notification marked as read" });
    }
    catch (err) {
        next(err);
    }
});
export default router;
//# sourceMappingURL=notifications.routes.js.map