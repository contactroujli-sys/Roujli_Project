export interface ConversationWithDetails {
    id: string;
    userId: string;
    businessId: string;
    lastMessageAt: Date | null;
    createdAt: Date;
    business: {
        id: string;
        name: string;
        logo: string | null;
    };
    messages: {
        id: string;
        body: string;
        senderId: string;
        senderRole: string;
        createdAt: Date;
    }[];
}
export interface SendMessageDto {
    body: string;
    senderRole: "USER" | "BUSINESS";
}
//# sourceMappingURL=messages.types.d.ts.map