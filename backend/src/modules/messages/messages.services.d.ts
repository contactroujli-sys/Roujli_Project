export declare function getUserConversations(userId: string): Promise<({
    business: {
        id: string;
        logo: string | null;
        name: string;
    };
    messages: {
        id: string;
        body: string;
        conversationId: string;
        senderId: string;
        senderRole: string;
        isRead: boolean;
        createdAt: Date;
    }[];
} & {
    id: string;
    userId: string;
    businessId: string;
    lastMessageAt: Date | null;
    createdAt: Date;
})[]>;
export declare function getOrCreateConversation(userId: string, businessId: string): Promise<{
    business: {
        id: string;
        logo: string | null;
        name: string;
    };
} & {
    id: string;
    userId: string;
    businessId: string;
    lastMessageAt: Date | null;
    createdAt: Date;
}>;
export declare function getConversationMessages(conversationId: string): Promise<{
    id: string;
    body: string;
    conversationId: string;
    senderId: string;
    senderRole: string;
    isRead: boolean;
    createdAt: Date;
}[]>;
export declare function createMessage(data: {
    conversationId: string;
    body: string;
    senderId: string;
    senderRole: string;
}): Promise<{
    id: string;
    body: string;
    conversationId: string;
    senderId: string;
    senderRole: string;
    isRead: boolean;
    createdAt: Date;
}>;
export declare function markConversationAsRead(conversationId: string, role: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
//# sourceMappingURL=messages.services.d.ts.map