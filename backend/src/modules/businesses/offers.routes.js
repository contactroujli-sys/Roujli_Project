import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { PrismaClient } from "@prisma/client";
import * as repo from "./offers.repository.js";
const router = Router();
const prisma = new PrismaClient();
async function getBusinessByUserId(userId) {
    const business = await prisma.business.findUnique({ where: { ownerId: userId } });
    if (!business)
        throw new Error("You must create a business profile first");
    return business;
}
router.get("/", async (req, res, next) => {
    try {
        const businessId = req.query.businessId;
        if (!businessId) {
            return res.status(400).json({ success: false, message: "businessId query parameter is required" });
        }
        const offers = await repo.getOffersByBusiness(businessId);
        res.status(200).json({ success: true, data: offers });
    }
    catch (err) {
        next(err);
    }
});
router.post("/", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        const { title, description, discount, image, expiresAt } = req.body;
        const business = await getBusinessByUserId(userId);
        const data = { title: String(title) };
        if (description !== undefined)
            data.description = String(description);
        if (discount !== undefined)
            data.discount = parseFloat(discount);
        if (image !== undefined)
            data.image = String(image);
        if (expiresAt !== undefined)
            data.expiresAt = new Date(expiresAt);
        const offer = await repo.createOffer(business.id, data);
        res.status(201).json({ success: true, data: offer });
    }
    catch (err) {
        next(err);
    }
});
router.put("/:id", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        const id = req.params.id;
        const { title, description, discount, image, expiresAt } = req.body;
        const business = await getBusinessByUserId(userId);
        const data = {};
        if (title !== undefined)
            data.title = String(title);
        if (description !== undefined)
            data.description = String(description);
        if (discount !== undefined)
            data.discount = parseFloat(discount);
        if (image !== undefined)
            data.image = String(image);
        if (expiresAt !== undefined)
            data.expiresAt = new Date(expiresAt);
        const offer = await repo.updateOffer(id, business.id, data);
        res.status(200).json({ success: true, data: offer });
    }
    catch (err) {
        next(err);
    }
});
router.delete("/:id", authenticate, async (req, res, next) => {
    try {
        const userId = req.userId;
        const id = req.params.id;
        const business = await getBusinessByUserId(userId);
        await repo.deleteOffer(id, business.id);
        res.status(200).json({ success: true, message: "Offer deleted" });
    }
    catch (err) {
        next(err);
    }
});
export default router;
//# sourceMappingURL=offers.routes.js.map