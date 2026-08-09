import { Router, type Request, type Response, type NextFunction } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as repo from "./requests.repository.js";
import { RequestType, RequestStatus } from "@prisma/client";

const router = Router();

router.post("/", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const { businessId, type, productId, serviceId, offerId, name, phone, email, note, quantity, preferredDate } = req.body;

    const data: any = {
      businessId: String(businessId),
      type: type as RequestType,
      name: String(name),
      quantity: quantity ? parseInt(quantity) : 1,
    };
    if (productId !== undefined) data.productId = String(productId);
    if (serviceId !== undefined) data.serviceId = String(serviceId);
    if (offerId !== undefined) data.offerId = String(offerId);
    if (phone !== undefined) data.phone = String(phone);
    if (email !== undefined) data.email = String(email);
    if (note !== undefined) data.note = String(note);
    if (preferredDate !== undefined) data.preferredDate = new Date(preferredDate);

    const request = await repo.createRequest(userId, data);
    res.status(201).json({ success: true, data: request });
  } catch (err) {
    next(err);
  }
});

router.get("/my", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const requests = await repo.getMyRequests(userId);
    res.status(200).json({ success: true, data: requests });
  } catch (err) {
    next(err);
  }
});

router.get("/incoming", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const requests = await repo.getIncomingRequests(userId);
    res.status(200).json({ success: true, data: requests });
  } catch (err) {
    next(err);
  }
});

router.get("/:id", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    const request = await repo.getRequestById(id, userId);
    if (!request) return res.status(404).json({ success: false, message: "Request not found" });
    res.status(200).json({ success: true, data: request });
  } catch (err) {
    next(err);
  }
});

router.patch("/:id/status", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    const { status, ownerNote } = req.body;

    const updated = await repo.updateRequestStatus(id, userId, status as RequestStatus, ownerNote ? String(ownerNote) : undefined);
    res.status(200).json({ success: true, data: updated });
  } catch (err) {
    next(err);
  }
});

export default router;
