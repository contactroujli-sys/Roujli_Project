import type { Request, Response, NextFunction } from "express";
import * as services from "./messages.services.js";

export async function getUserConversations(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const conversations = await services.getUserConversations(userId);
    res.status(200).json({ success: true, data: conversations });
  } catch (err) {
    next(err);
  }
}

export async function getConversationMessages(req: Request, res: Response, next: NextFunction) {
  try {
    const conversationId = req.params.conversationId as string;
    const messages = await services.getConversationMessages(conversationId);
    
    // Auto mark as read based on current role (usually USER on mobile app)
    const userRole = req.user?.role || "CUSTOMER";
    const senderRole = userRole === "BUSINESS" ? "BUSINESS" : "USER";
    await services.markConversationAsRead(conversationId, senderRole);

    res.status(200).json({ success: true, data: messages });
  } catch (err) {
    next(err);
  }
}

export async function startConversation(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const businessId = req.params.businessId as string;
    const conversation = await services.getOrCreateConversation(userId, businessId);
    res.status(200).json({ success: true, data: conversation });
  } catch (err) {
    next(err);
  }
}
