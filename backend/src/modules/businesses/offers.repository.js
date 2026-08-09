import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
export async function createOffer(businessId, data) {
    const createData = {
        title: data.title,
        businessId,
    };
    if (data.description !== undefined)
        createData.description = data.description;
    if (data.discount !== undefined)
        createData.discount = data.discount;
    if (data.image !== undefined)
        createData.image = data.image;
    if (data.expiresAt !== undefined)
        createData.expiresAt = data.expiresAt;
    return prisma.offer.create({ data: createData });
}
export async function getOffersByBusiness(businessId) {
    return prisma.offer.findMany({
        where: { businessId },
        orderBy: { createdAt: "desc" },
    });
}
export async function updateOffer(id, businessId, data) {
    const existing = await prisma.offer.findFirst({ where: { id, businessId } });
    if (!existing)
        throw new Error("Offer not found or access denied");
    const updateData = {};
    if (data.title !== undefined)
        updateData.title = data.title;
    if (data.description !== undefined)
        updateData.description = data.description;
    if (data.discount !== undefined)
        updateData.discount = data.discount;
    if (data.image !== undefined)
        updateData.image = data.image;
    if (data.expiresAt !== undefined)
        updateData.expiresAt = data.expiresAt;
    return prisma.offer.update({
        where: { id },
        data: updateData,
    });
}
export async function deleteOffer(id, businessId) {
    const existing = await prisma.offer.findFirst({ where: { id, businessId } });
    if (!existing)
        throw new Error("Offer not found or access denied");
    return prisma.offer.delete({ where: { id } });
}
//# sourceMappingURL=offers.repository.js.map