import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
export async function getUserNotifications(userId) {
    return prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: "desc" },
        take: 50,
    });
}
export async function getUnreadCount(userId) {
    const count = await prisma.notification.count({
        where: { userId, isRead: false },
    });
    return { unreadCount: count };
}
export async function markAsRead(id, userId) {
    return prisma.notification.updateMany({
        where: { id, userId },
        data: { isRead: true },
    });
}
export async function markAllAsRead(userId) {
    return prisma.notification.updateMany({
        where: { userId, isRead: false },
        data: { isRead: true },
    });
}
//# sourceMappingURL=notifications.repository.js.map