import { Router } from "express";
import { optionalAuth } from "../../middlewares/auth.middleware.js";
import * as controller from "./home.controller.js";

const router = Router();

/**
 * @route   GET /api/home
 * @desc    Get home screen data (stats, businesses, offers, etc.)
 * @access  Public (optional authentication for personalized data)
 */
router.get("/", optionalAuth, controller.getHomeData);

export default router;
