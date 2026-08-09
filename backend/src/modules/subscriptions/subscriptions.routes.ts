import { Router, type Request, type Response, type NextFunction } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as service from "./subscriptions.services.js";
import { SubscriptionType } from "@prisma/client";

const router = Router();

// GET /api/subscriptions/plans
router.get("/plans", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const plans = await service.getPlans();
    res.status(200).json({ success: true, data: plans });
  } catch (err) {
    next(err);
  }
});

// GET /api/subscriptions/add-ons
router.get("/add-ons", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const addOns = await service.getAddOns();
    res.status(200).json({ success: true, data: addOns });
  } catch (err) {
    next(err);
  }
});

// GET /api/subscriptions/my
router.get("/my", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const subscription = await service.getMySubscription(userId);
    res.status(200).json({ success: true, data: subscription });
  } catch (err) {
    next(err);
  }
});

// POST /api/subscriptions/subscribe
router.post("/subscribe", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const { planType } = req.body;
    if (!planType || !Object.values(SubscriptionType).includes(planType)) {
      return res.status(400).json({ success: false, message: "Valid planType is required (START, GROW, SCALE, ENTERPRISE)" });
    }

    const subscription = await service.subscribeToPlan(userId, planType as SubscriptionType);
    res.status(200).json({ success: true, data: subscription, message: `Successfully subscribed to ${planType} plan` });
  } catch (err) {
    next(err);
  }
});

export default router;
