import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as controller from "./products.controller.js";

const router = Router();

router.get("/", controller.getProducts);
router.post("/", authenticate, controller.createProduct);
router.put("/:id", authenticate, controller.updateProduct);
router.delete("/:id", authenticate, controller.deleteProduct);

export default router;
