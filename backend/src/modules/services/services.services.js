import * as repo from "./services.repository.js";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function getBusinessByUserId(userId) {
    const business = await prisma.business.findUnique({ where: { ownerId: userId } });
    if (!business)
        throw new Error("You must create a business profile first");
    return business;
}
export async function createService(userId, data) {
    const business = await getBusinessByUserId(userId);
    return repo.createService(business.id, data);
}
export async function getServices(businessId) {
    return repo.getServicesByBusiness(businessId);
}
export async function updateService(userId, id, data) {
    const business = await getBusinessByUserId(userId);
    return repo.updateService(id, business.id, data);
}
export async function deleteService(userId, id) {
    const business = await getBusinessByUserId(userId);
    return repo.deleteService(id, business.id);
}
//# sourceMappingURL=services.services.js.map