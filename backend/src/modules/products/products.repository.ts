import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function createProduct(businessId: string, data: { name: string; description?: string; price: number; image?: string }) {
  const createData: any = {
    name: data.name,
    price: data.price,
    businessId,
  };
  if (data.description !== undefined) createData.description = data.description;
  if (data.image !== undefined) createData.image = data.image;

  return prisma.product.create({ data: createData });
}

export async function getProductsByBusiness(businessId: string) {
  return prisma.product.findMany({
    where: { businessId },
    orderBy: { createdAt: "desc" },
  });
}

export async function updateProduct(id: string, businessId: string, data: { name?: string; description?: string; price?: number; image?: string }) {
  const existing = await prisma.product.findFirst({ where: { id, businessId } });
  if (!existing) throw new Error("Product not found or access denied");
  
  const updateData: any = {};
  if (data.name !== undefined) updateData.name = data.name;
  if (data.description !== undefined) updateData.description = data.description;
  if (data.price !== undefined) updateData.price = data.price;
  if (data.image !== undefined) updateData.image = data.image;

  return prisma.product.update({
    where: { id },
    data: updateData,
  });
}

export async function deleteProduct(id: string, businessId: string) {
  const existing = await prisma.product.findFirst({ where: { id, businessId } });
  if (!existing) throw new Error("Product not found or access denied");
  return prisma.product.delete({ where: { id } });
}
