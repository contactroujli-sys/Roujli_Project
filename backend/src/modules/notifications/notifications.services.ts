import { NotificationType } from "@prisma/client";
import * as repo from "./notifications.repository.js";
import { sendOneSignalPush } from "../../services/onesignal.service.js";

export interface SendNotificationOptions {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, any>;
  requestId?: string | null;
}

/**
 * Centralized Notification Service for ROUJLI.
 * Creates DB record in PostgreSQL first, then dispatches OneSignal push asynchronously.
 */
export async function sendNotification(options: SendNotificationOptions) {
  // 1. Create DB Record (Source of Truth in PostgreSQL)
  const notification = await repo.createNotification({
    userId: options.userId,
    type: options.type,
    title: options.title,
    body: options.body,
    data: options.data,
    requestId: options.requestId ?? null,
  });

  // 2. Asynchronous Non-Blocking OneSignal Push Delivery
  setImmediate(async () => {
    try {
      await sendOneSignalPush({
        userIds: [options.userId],
        title: options.title,
        body: options.body,
        data: {
          notificationId: notification.id,
          type: options.type.toLowerCase(),
          ...(options.data || {}),
        },
      });
    } catch (err) {
      console.error(`[Notification Service] Failed to deliver push for user ${options.userId}:`, err);
    }
  });

  return notification;
}
