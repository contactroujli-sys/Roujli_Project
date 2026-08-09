import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function createService(businessId: string, data: { name: string; description?: string; price: number; duration?: number; image?: string }) {
  const createData: any = {
    name: data.name,
    price: data.price,
    businessId,
  };
  if (data.description !== undefined) createData.description = data.description;
  if (data.duration !== undefined) createData.duration = data.duration;
  if (data.image !== undefined) createData.image = data.image;

  return prisma.service.create({ data: createData });
}

export async function getServicesByBusiness(businessId: string) {
  return prisma.service.findMany({
    where: { businessId },
    orderBy: { createdAt: "desc" },
  });
}

export async function updateService(id: string, businessId: string, data: { name?: string; description?: string; price?: number; duration?: number; image?: string }) {
  const existing = await prisma.service.findFirst({ where: { id, businessId } });
  if (!existing) throw new Error("Service not found or access denied");
  
  const updateData: any = {};
  if (data.name !== undefined) updateData.name = data.name;
  if (data.description !== undefined) updateData.description = data.description;
  if (data.price !== undefined) updateData.price = data.price;
  if (data.duration !== undefined) updateData.duration = data.duration;
  if (data.image !== undefined) updateData.image = data.image;

  return prisma.service.update({
    where: { id },
    data: updateData,
  });
}

export async function deleteService(id: string, businessId: string) {
  const existing = await prisma.service.findFirst({ where: { id, businessId } });
  if (!existing) throw new Error("Service not found or access denied");
  return prisma.service.delete({ where: { id } });
}
