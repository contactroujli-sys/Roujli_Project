import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import { swaggerSpec, swaggerUi } from "./config/swagger.js";
import authRouter from "./modules/auth/auth.routes.js";
import homeRouter from "./modules/home/home.routes.js";
import profilesRouter from "./modules/profiles/profiles.routes.js";
import productsRouter from "./modules/products/products.routes.js";
import servicesRouter from "./modules/services/services.routes.js";
import businessesRouter from "./modules/businesses/businesses.routes.js";
import offersRouter from "./modules/businesses/offers.routes.js";
import categoriesRouter from "./modules/categories/categories.routes.js";
import requestsRouter from "./modules/requests/requests.routes.js";
import notificationsRouter from "./modules/notifications/notifications.routes.js";
import messagesRouter from "./modules/messages/messages.routes.js";
import { notFound } from "./middlewares/notFound.middleware.js";
import { errorHandler } from "./middlewares/error.middleware.js";
const app = express();
// ─── Core Middlewares ─────────────────────────────────────────────────────────
app.use(cors());
app.use(helmet());
app.use(morgan("dev"));
app.use(express.json());
// ─── Swagger Docs ─────────────────────────────────────────────────────────────
app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
// ─── Health Check ─────────────────────────────────────────────────────────────
app.get("/", (_req, res) => {
    res.json({
        success: true,
        message: "ROUJLI API is running 🚀",
    });
});
// ─── API Routes ───────────────────────────────────────────────────────────────
app.use("/api/auth", authRouter);
app.use("/api/home", homeRouter);
app.use("/api/profile", profilesRouter);
app.use("/api/products", productsRouter);
app.use("/api/services", servicesRouter);
app.use("/api/offers", offersRouter);
app.use("/api/businesses", businessesRouter);
app.use("/api/categories", categoriesRouter);
app.use("/api/requests", requestsRouter);
app.use("/api/notifications", notificationsRouter);
app.use("/api/messages", messagesRouter);
// ─── Error Handling ───────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);
export default app;
//# sourceMappingURL=app.js.map