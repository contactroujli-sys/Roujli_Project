export declare function getUserNotifications(userId: string): Promise<{
    id: string;
    type: import("@prisma/client").$Enums.NotificationType;
    message: string;
    isRead: boolean;
    userId: string;
    requestId: string | null;
    createdAt: Date;
}[]>;
export declare function getUnreadCount(userId: string): Promise<{
    unreadCount: number;
}>;
export declare function markAsRead(id: string, userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
export declare function markAllAsRead(userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
//# sourceMappingURL=notifications.repository.d.ts.map