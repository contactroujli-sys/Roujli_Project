import { Server } from "socket.io";
import { verifyAccessToken } from "../utils/jwt.js";
import * as services from "../modules/messages/messages.services.js";
import logger from "../utils/logger.js";
export function initSocketServer(httpServer) {
    const io = new Server(httpServer, {
        cors: {
            origin: "*",
            methods: ["GET", "POST"],
        },
    });
    // Authenticate socket handshake using JWT
    io.use((socket, next) => {
        const token = socket.handshake.auth.token || socket.handshake.query.token;
        if (!token) {
            return next(new Error("Authentication required. No token provided."));
        }
        try {
            const decoded = verifyAccessToken(token);
            socket.data.user = decoded;
            next();
        }
        catch {
            next(new Error("Invalid or expired token."));
        }
    });
    io.on("connection", (socket) => {
        const user = socket.data.user;
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
            if (!body || body.trim() === "")
                return;
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
            }
            catch (err) {
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
//# sourceMappingURL=socket.js.map