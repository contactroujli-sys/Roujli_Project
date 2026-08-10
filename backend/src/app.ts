import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import path from "path";
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
import adminRouter from "./modules/admin/admin.routes.js";
import subscriptionsRouter from "./modules/subscriptions/subscriptions.routes.js";
import { notFound } from "./middlewares/notFound.middleware.js";
import { errorHandler } from "./middlewares/error.middleware.js";
import { authenticate } from "./middlewares/auth.middleware.js";
import { upload } from "./middlewares/upload.middleware.js";

const app = express();

// ─── Core Middlewares ─────────────────────────────────────────────────────────

app.use(cors());
const helmetFn: any = (helmet as any).default || helmet;
app.use(helmetFn({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
app.use(morgan("dev"));
app.use(express.json());

// ─── Static Files (uploaded images) ──────────────────────────────────────────

app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));

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
app.use("/api/admin", adminRouter);
app.use("/api/subscriptions", subscriptionsRouter);

// ─── Upload Endpoint ──────────────────────────────────────────────────────────

app.post("/api/upload", authenticate, upload.single("image"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: "No image file uploaded." });
  }
  const baseUrl = `${req.protocol}://${req.get("host")}`;
  const imageUrl = `${baseUrl}/uploads/${req.file.filename}`;
  res.status(200).json({ success: true, data: { url: imageUrl } });
});

// ─── Error Handling ───────────────────────────────────────────────────────────

app.use(notFound);
app.use(errorHandler);

export default app;