import * as repo from "./products.repository.js";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function getBusinessByUserId(userId) {
    const business = await prisma.business.findUnique({ where: { ownerId: userId } });
    if (!business)
        throw new Error("You must create a business profile first");
    return business;
}
export async function createProduct(userId, data) {
    const business = await getBusinessByUserId(userId);
    return repo.createProduct(business.id, data);
}
export async function getProducts(businessId) {
    return repo.getProductsByBusiness(businessId);
}
export async function updateProduct(userId, id, data) {
    const business = await getBusinessByUserId(userId);
    return repo.updateProduct(id, business.id, data);
}
export async function deleteProduct(userId, id) {
    const business = await getBusinessByUserId(userId);
    return repo.deleteProduct(id, business.id);
}
//# sourceMappingURL=products.services.js.map