import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function getUserConversations(userId: string) {
  const userBusiness = await prisma.business.findUnique({
    where: { ownerId: userId },
    select: { id: true },
  });

  const whereCondition = userBusiness
    ? { OR: [{ userId }, { businessId: userBusiness.id }] }
    : { userId };

  return prisma.conversation.findMany({
    where: whereCondition,
    include: {
      user: {
        select: {
          id: true,
          profile: {
            select: {
              firstName: true,
              lastName: true,
              avatar: true,
            },
          },
        },
      },
      business: {
        select: {
          id: true,
          name: true,
          logo: true,
        },
      },
      messages: {
        orderBy: { createdAt: "desc" },
        take: 1,
      },
      _count: {
        select: {
          messages: {
            where: { isRead: false },
          },
        },
      },
    },
    orderBy: { lastMessageAt: "desc" },
  });
}

export async function getOrCreateConversation(userId: string, businessId: string) {
  // Try finding existing first
  const existing = await prisma.conversation.findUnique({
    where: {
      userId_businessId: {
        userId,
        businessId,
      },
    },
    include: {
      business: {
        select: {
          id: true,
          name: true,
          logo: true,
        },
      },
    },
  });

  if (existing) return existing;

  // Create new
  return prisma.conversation.create({
    data: {
      userId,
      businessId,
    },
    include: {
      business: {
        select: {
          id: true,
          name: true,
          logo: true,
        },
      },
    },
  });
}

export async function getConversationMessages(conversationId: string, limit = 50) {
  return prisma.message.findMany({
    where: { conversationId },
    orderBy: { createdAt: "asc" },
    take: limit,
  });
}

export async function createMessage(data: {
  conversationId: string;
  body: string;
  senderId: string;
  senderRole: string;
}) {
  const [message] = await prisma.$transaction([
    prisma.message.create({
      data,
    }),
    prisma.conversation.update({
      where: { id: data.conversationId },
      data: { lastMessageAt: new Date() },
    }),
  ]);
  return message;
}

export async function markConversationRead(conversationId: string, senderRoleToMarkRead: string) {
  return prisma.message.updateMany({
    where: {
      conversationId,
      senderRole: senderRoleToMarkRead === "USER" ? "BUSINESS" : "USER",
      isRead: false,
    },
    data: { isRead: true },
  });
}
