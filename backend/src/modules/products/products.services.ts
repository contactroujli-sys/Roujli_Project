import * as repo from "./products.repository.js";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function getBusinessByUserId(userId: string) {
  const business = await prisma.business.findUnique({ where: { ownerId: userId } });
  if (!business) throw new Error("You must create a business profile first");
  return business;
}

export async function createProduct(userId: string, data: { name: string; description?: string; price: number; image?: string }) {
  const business = await getBusinessByUserId(userId);
  return repo.createProduct(business.id, data);
}

export async function getProducts(businessId: string) {
  return repo.getProductsByBusiness(businessId);
}

export async function updateProduct(userId: string, id: string, data: { name?: string; description?: string; price?: number; image?: string }) {
  const business = await getBusinessByUserId(userId);
  return repo.updateProduct(id, business.id, data);
}

export async function deleteProduct(userId: string, id: string) {
  const business = await getBusinessByUserId(userId);
  return repo.deleteProduct(id, business.id);
}
