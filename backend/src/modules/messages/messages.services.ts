import * as repo from "./messages.repository.js";

export async function getUserConversations(userId: string) {
  return repo.getUserConversations(userId);
}

export async function getOrCreateConversation(userId: string, businessId: string) {
  return repo.getOrCreateConversation(userId, businessId);
}

export async function getConversationMessages(conversationId: string) {
  return repo.getConversationMessages(conversationId);
}

import { NotificationType } from "@prisma/client";
import { sendNotification } from "../notifications/notifications.services.js";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function createMessage(data: {
  conversationId: string;
  body: string;
  senderId: string;
  senderRole: string;
}) {
  const message = await repo.createMessage(data);

  // Trigger push notification asynchronously
  setImmediate(async () => {
    try {
      const conversation = await prisma.conversation.findUnique({
        where: { id: data.conversationId },
        include: { business: true },
      });
      if (conversation) {
        const recipientId = data.senderRole === "USER" ? conversation.business.ownerId : conversation.userId;
        if (recipientId && recipientId !== data.senderId) {
          await sendNotification({
            userId: recipientId,
            type: NotificationType.NEW_MESSAGE,
            title: "New Message",
            body: "You received a new message.",
            data: {
              type: "new_message",
              conversationId: data.conversationId,
            },
          });
        }
      }
    } catch (err) {
      console.error("[Message Notification Error]", err);
    }
  });

  return message;
}

export async function markConversationAsRead(conversationId: string, role: string) {
  return repo.markConversationRead(conversationId, role);
}
