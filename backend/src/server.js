import dotenv from "dotenv";
dotenv.config();
import http from "http";
import app from "./app.js";
import { initSocketServer } from "./socket/socket.js";
import logger from "./utils/logger.js";
const PORT = Number(process.env.PORT) || 5000;
const HOST = process.env.HOST || "0.0.0.0";
const httpServer = http.createServer(app);
initSocketServer(httpServer);
httpServer.listen(PORT, HOST, () => {
    logger.info(`Server running on http://${HOST}:${PORT}`);
});
//# sourceMappingURL=server.js.map