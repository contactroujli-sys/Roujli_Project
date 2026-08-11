import dotenv from "dotenv";
dotenv.config();

import http from "http";
import app from "./app.js";
import { initSocketServer } from "./socket/socket.js";
import logger from "./utils/logger.js";

const PORT = Number(process.env.PORT) || 5000;
const HOST = process.env.HOST || "0.0.0.0";

if (!process.env.VERCEL) {
  const httpServer = http.createServer(app);
  const io = initSocketServer(httpServer);

  const server = httpServer.listen(PORT, HOST, () => {
    logger.info(`Server running on http://${HOST}:${PORT}`);
    logger.info(`Socket.IO initialized and listening for connections.`);
  });

  const gracefulShutdown = (signal: string) => {
    logger.info(`${signal} received. Closing HTTP server and Socket.IO...`);
    io.close(() => {
      logger.info("Socket.IO connections closed.");
    });
    server.close(() => {
      logger.info("HTTP server closed.");
      process.exit(0);
    });
  };

  process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
  process.on("SIGINT", () => gracefulShutdown("SIGINT"));
}

export default app;