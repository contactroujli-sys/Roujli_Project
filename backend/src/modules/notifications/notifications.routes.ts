import { Router, type Request, type Response, type NextFunction } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as repo from "./notifications.repository.js";

const router = Router();

router.get("/", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const notifications = await repo.getUserNotifications(userId);
    res.status(200).json({ success: true, data: notifications });
  } catch (err) {
    next(err);
  }
});

router.get("/unread-count", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const data = await repo.getUnreadCount(userId);
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
});

router.patch("/read-all", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    await repo.markAllAsRead(userId);
    res.status(200).json({ success: true, message: "All notifications marked as read" });
  } catch (err) {
    next(err);
  }
});

router.patch("/:id/read", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    await repo.markAsRead(id, userId);
    res.status(200).json({ success: true, message: "Notification marked as read" });
  } catch (err) {
    next(err);
  }
});

export default router;
