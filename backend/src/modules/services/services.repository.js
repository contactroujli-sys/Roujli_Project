import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
export async function createService(businessId, data) {
    const createData = {
        name: data.name,
        price: data.price,
        businessId,
    };
    if (data.description !== undefined)
        createData.description = data.description;
    if (data.duration !== undefined)
        createData.duration = data.duration;
    if (data.image !== undefined)
        createData.image = data.image;
    return prisma.service.create({ data: createData });
}
export async function getServicesByBusiness(businessId) {
    return prisma.service.findMany({
        where: { businessId },
        orderBy: { createdAt: "desc" },
    });
}
export async function updateService(id, businessId, data) {
    const existing = await prisma.service.findFirst({ where: { id, businessId } });
    if (!existing)
        throw new Error("Service not found or access denied");
    const updateData = {};
    if (data.name !== undefined)
        updateData.name = data.name;
    if (data.description !== undefined)
        updateData.description = data.description;
    if (data.price !== undefined)
        updateData.price = data.price;
    if (data.duration !== undefined)
        updateData.duration = data.duration;
    if (data.image !== undefined)
        updateData.image = data.image;
    return prisma.service.update({
        where: { id },
        data: updateData,
    });
}
export async function deleteService(id, businessId) {
    const existing = await prisma.service.findFirst({ where: { id, businessId } });
    if (!existing)
        throw new Error("Service not found or access denied");
    return prisma.service.delete({ where: { id } });
}
//# sourceMappingURL=services.repository.js.map