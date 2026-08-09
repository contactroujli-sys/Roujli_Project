import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import * as controller from "./profiles.controller.js";
import { updateProfileSchema, updateBusinessSchema } from "./profiles.schema.js";
const router = Router();
/**
 * @route   GET /api/profile
 * @desc    Get user profile data
 * @access  Private (requires authentication)
 */
router.get("/", authenticate, controller.getProfileData);
/**
 * @route   PUT /api/profile
 * @desc    Update user profile data
 * @access  Private (requires authentication)
 */
router.put("/", authenticate, validate(updateProfileSchema), controller.updateProfileData);
/**
 * @route   PUT /api/profile/business
 * @desc    Update business data
 * @access  Private (requires authentication)
 */
router.put("/business", authenticate, validate(updateBusinessSchema), controller.updateBusinessData);
router.delete("/business", authenticate, controller.deleteBusiness);
export default router;
//# sourceMappingURL=profiles.routes.js.map