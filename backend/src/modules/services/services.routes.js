import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as controller from "./services.controller.js";
const router = Router();
router.get("/", controller.getServices);
router.post("/", authenticate, controller.createService);
router.put("/:id", authenticate, controller.updateService);
router.delete("/:id", authenticate, controller.deleteService);
export default router;
//# sourceMappingURL=services.routes.js.map