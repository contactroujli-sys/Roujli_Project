import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
export async function getUserConversations(userId) {
    return prisma.conversation.findMany({
        where: { userId },
        include: {
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
        },
        orderBy: { lastMessageAt: "desc" },
    });
}
export async function getOrCreateConversation(userId, businessId) {
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
    if (existing)
        return existing;
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
export async function getConversationMessages(conversationId, limit = 50) {
    return prisma.message.findMany({
        where: { conversationId },
        orderBy: { createdAt: "asc" },
        take: limit,
    });
}
export async function createMessage(data) {
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
export async function markConversationRead(conversationId, senderRoleToMarkRead) {
    return prisma.message.updateMany({
        where: {
            conversationId,
            senderRole: senderRoleToMarkRead === "USER" ? "BUSINESS" : "USER",
            isRead: false,
        },
        data: { isRead: true },
    });
}
//# sourceMappingURL=messages.repository.js.map