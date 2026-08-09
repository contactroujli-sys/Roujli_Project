import { PrismaClient, RequestType, RequestStatus, NotificationType } from "@prisma/client";

const prisma = new PrismaClient();

export async function createRequest(userId: string, data: {
  businessId: string;
  type: RequestType;
  productId?: string;
  serviceId?: string;
  offerId?: string;
  name: string;
  phone?: string;
  email?: string;
  note?: string;
  quantity?: number;
  preferredDate?: Date;
}) {
  const createData: any = {
    userId,
    businessId: data.businessId,
    type: data.type,
    name: data.name,
    quantity: data.quantity ?? 1,
  };
  if (data.productId !== undefined) createData.productId = data.productId;
  if (data.serviceId !== undefined) createData.serviceId = data.serviceId;
  if (data.offerId !== undefined) createData.offerId = data.offerId;
  if (data.phone !== undefined) createData.phone = data.phone;
  if (data.email !== undefined) createData.email = data.email;
  if (data.note !== undefined) createData.note = data.note;
  if (data.preferredDate !== undefined) createData.preferredDate = data.preferredDate;

  const req = await prisma.request.create({
    data: createData,
    include: {
      business: true,
      product: true,
      service: true,
      offer: true,
    },
  });

  // Create notification for business owner
  const business = await prisma.business.findUnique({ where: { id: data.businessId } });
  if (business) {
    await prisma.notification.create({
      data: {
        userId: business.ownerId,
        type: NotificationType.NEW_REQUEST,
        message: `New request from ${data.name} for ${business.name}`,
        requestId: req.id,
      },
    });
  }

  return req;
}

export async function getMyRequests(userId: string) {
  return prisma.request.findMany({
    where: { userId },
    include: {
      business: { select: { id: true, name: true, logo: true } },
      product: { select: { id: true, name: true, price: true } },
      service: { select: { id: true, name: true, price: true } },
      offer: { select: { id: true, title: true, discount: true } },
    },
    orderBy: { createdAt: "desc" },
  });
}

export async function getIncomingRequests(userId: string) {
  const business = await prisma.business.findUnique({ where: { ownerId: userId } });
  if (!business) return [];

  return prisma.request.findMany({
    where: { businessId: business.id },
    include: {
      user: { select: { id: true, email: true, profile: true } },
      product: { select: { id: true, name: true, price: true } },
      service: { select: { id: true, name: true, price: true } },
      offer: { select: { id: true, title: true, discount: true } },
    },
    orderBy: { createdAt: "desc" },
  });
}

export async function getRequestById(id: string, userId: string) {
  const req = await prisma.request.findUnique({
    where: { id },
    include: {
      business: { select: { id: true, name: true, logo: true, ownerId: true } },
      user: { select: { id: true, email: true, profile: true } },
      product: true,
      service: true,
      offer: true,
    },
  });

  if (!req) return null;
  if (req.userId !== userId && req.business.ownerId !== userId) {
    throw new Error("Access denied");
  }

  return req;
}

export async function updateRequestStatus(id: string, ownerUserId: string, status: RequestStatus, ownerNote?: string) {
  const req = await prisma.request.findUnique({
    where: { id },
    include: { business: true },
  });

  if (!req) throw new Error("Request not found");
  if (req.business.ownerId !== ownerUserId) throw new Error("Only business owner can update request status");

  const updateData: any = { status };
  if (ownerNote !== undefined) updateData.ownerNote = ownerNote;

  const updated = await prisma.request.update({
    where: { id },
    data: updateData,
  });

  const notifType = status === RequestStatus.ACCEPTED ? NotificationType.REQUEST_ACCEPTED : NotificationType.REQUEST_REJECTED;
  const statusStr = status === RequestStatus.ACCEPTED ? "accepted" : "rejected";

  await prisma.notification.create({
    data: {
      userId: req.userId,
      type: notifType,
      message: `Your request to ${req.business.name} was ${statusStr}`,
      requestId: req.id,
    },
  });

  return updated;
}
