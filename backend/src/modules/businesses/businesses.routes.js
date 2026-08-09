import { Router } from "express";
import { authenticate, optionalAuth } from "../../middlewares/auth.middleware.js";
import * as controller from "./businesses.controller.js";
const router = Router();
router.get("/", optionalAuth, controller.getBusinesses);
router.get("/saved", authenticate, controller.getSaved);
router.get("/:id", optionalAuth, controller.getBusinessById);
router.post("/:id/save", authenticate, controller.toggleSave);
router.post("/:id/follow", authenticate, controller.toggleFollow);
export default router;
//# sourceMappingURL=businesses.routes.js.map