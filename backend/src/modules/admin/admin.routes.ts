import { Router } from "express";
import * as adminController from "./admin.controller.js";
import { authenticate, authorizeRoles } from "../../middlewares/auth.middleware.js";

const router = Router();

// Secure all admin routes
router.use(authenticate);
router.use(authorizeRoles("ADMIN"));

// Stats & Analytics
router.get("/stats", adminController.getDashboardStats);
router.get("/analytics", adminController.getAnalytics);

// Search
router.get("/search", adminController.globalSearch);

// Admin Profile & Settings
router.get("/profile", adminController.getAdminProfile);
router.put("/profile", adminController.updateAdminProfile);
router.get("/settings", adminController.getSettings);
router.put("/settings", adminController.updateSettings);

// Users
router.get("/users", adminController.getAllUsers);
router.get("/users/:id", adminController.getUserById);
router.patch("/users/:id/role", adminController.updateUserRole);
router.patch("/users/:id/verify", adminController.toggleUserVerification);
router.delete("/users/:id", adminController.deleteUser);

// Businesses
router.get("/businesses", adminController.getAllBusinesses);
router.get("/businesses/:id", adminController.getBusinessById);
router.patch("/businesses/:id/verify", adminController.toggleBusinessVerification);
router.delete("/businesses/:id", adminController.deleteBusiness);

// Categories
router.get("/categories", adminController.getAllCategories);
router.post("/categories", adminController.createCategory);
router.put("/categories/:id", adminController.updateCategory);
router.delete("/categories/:id", adminController.deleteCategory);

// Products
router.get("/products", adminController.getAllProducts);
router.delete("/products/:id", adminController.deleteProduct);

// Services
router.get("/services", adminController.getAllServices);
router.delete("/services/:id", adminController.deleteService);

// Requests
router.get("/requests", adminController.getAllRequests);
router.patch("/requests/:id/status", adminController.updateRequestStatus);

// Subscriptions
router.get("/subscriptions", adminController.getAllSubscriptions);
router.get("/subscriptions/users", adminController.getUserSubscriptions);

// Notifications
router.get("/notifications", adminController.getAllNotifications);

// Reports
router.get("/reports", adminController.getAllReports);
router.patch("/reports/:id/status", adminController.updateReportStatus);

export default router;
