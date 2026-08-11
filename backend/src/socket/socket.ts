import { Server } from "socket.io";
import type { Server as HttpServer } from "http";
import { verifyAccessToken } from "../utils/jwt.js";
import * as services from "../modules/messages/messages.services.js";
import logger from "../utils/logger.js";

interface SocketUser {
  userId: string;
  email: string;
  role: string;
}

let ioInstance: Server | null = null;

export function getIO(): Server | null {
  return ioInstance;
}

export function broadcastMessage(conversationId: string, message: any) {
  if (ioInstance) {
    ioInstance.to(`conv:${conversationId}`).emit("new_message", message);
  }
}

export function initSocketServer(httpServer: HttpServer) {
  const io = new Server(httpServer, {
    pingTimeout: 20000,
    pingInterval: 25000,
    transports: ["websocket", "polling"],
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
    },
  });

  ioInstance = io;

  // Authenticate socket handshake using JWT
  io.use((socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.query.token;

    if (!token) {
      return next(new Error("Authentication required. No token provided."));
    }

    try {
      const decoded = verifyAccessToken(token) as SocketUser;
      socket.data.user = decoded;
      next();
    } catch {
      next(new Error("Invalid or expired token."));
    }
  });

  io.on("connection", (socket) => {
    const user = socket.data.user as SocketUser;
    logger.info(`Socket connected: User ${user.userId} (${user.role})`);

    // Join room for this user
    socket.join(`user:${user.userId}`);

    // Join conversation room
    socket.on("join_conversation", async ({ conversationId }) => {
      socket.join(`conv:${conversationId}`);
      logger.info(`User ${user.userId} joined conversation: ${conversationId}`);
      
      // Auto mark messages as read
      const senderRole = user.role === "BUSINESS" ? "BUSINESS" : "USER";
      await services.markConversationAsRead(conversationId, senderRole);
      
      // Broadcast read event to the room
      socket.to(`conv:${conversationId}`).emit("messages_read", { conversationId });
    });

    // Leave conversation room
    socket.on("leave_conversation", ({ conversationId }) => {
      socket.leave(`conv:${conversationId}`);
      logger.info(`User ${user.userId} left conversation: ${conversationId}`);
    });

    // Send message inside conversation
    socket.on("send_message", async ({ conversationId, body }) => {
      if (!body || body.trim() === "") return;

      try {
        const senderRole = user.role === "BUSINESS" ? "BUSINESS" : "USER";
        const message = await services.createMessage({
          conversationId,
          body,
          senderId: user.userId,
          senderRole,
        });

        // Broadcast new message to the room
        io.to(`conv:${conversationId}`).emit("new_message", message);
      } catch (err) {
        logger.error(`Failed to send message: ${err}`);
        socket.emit("error", { message: "Failed to send message" });
      }
    });

    // Typing indicators
    socket.on("typing", ({ conversationId }) => {
      socket.to(`conv:${conversationId}`).emit("user_typing", {
        conversationId,
        userId: user.userId,
      });
    });

    socket.on("stop_typing", ({ conversationId }) => {
      socket.to(`conv:${conversationId}`).emit("user_stop_typing", {
        conversationId,
        userId: user.userId,
      });
    });

    socket.on("disconnect", () => {
      logger.info(`Socket disconnected: User ${user.userId}`);
    });
  });

  return io;
}
