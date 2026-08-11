import { Router } from "express";
import { authenticate, optionalAuth } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import { updateBusinessSchema } from "../profiles/profiles.schema.js";
import * as controller from "./businesses.controller.js";

const router = Router();

router.get("/", optionalAuth, controller.getBusinesses);
router.post("/", authenticate, validate(updateBusinessSchema), controller.createBusiness);
router.get("/saved", authenticate, controller.getSaved);
router.get("/growth", authenticate, controller.getGrowthDetails);
router.get("/growth/history", authenticate, controller.getGrowthHistory);
router.get("/suggestions", optionalAuth, controller.getSuggestions);
router.get("/:id", optionalAuth, controller.getBusinessById);
router.post("/:id/save", authenticate, controller.toggleSave);
router.post("/:id/follow", authenticate, controller.toggleFollow);

export default router;
