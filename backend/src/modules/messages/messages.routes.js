import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as controller from "./messages.controller.js";
const router = Router();
router.get("/", authenticate, controller.getUserConversations);
router.get("/:conversationId", authenticate, controller.getConversationMessages);
router.post("/start/:businessId", authenticate, controller.startConversation);
export default router;
//# sourceMappingURL=messages.routes.js.map