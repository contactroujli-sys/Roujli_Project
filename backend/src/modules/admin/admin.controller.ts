import type { Request, Response, NextFunction } from "express";
import * as adminService from "./admin.services.js";
import { Role, ReportStatus, RequestStatus } from "@prisma/client";

// --- Stats ---
export async function getDashboardStats(req: Request, res: Response, next: NextFunction) {
  try {
    const stats = await adminService.getDashboardStats();
    res.status(200).json({ success: true, data: stats });
  } catch (err) {
    next(err);
  }
}

export async function globalSearch(req: Request, res: Response, next: NextFunction) {
  try {
    const query = req.query.q as string;
    if (!query) return res.status(200).json({ success: true, data: { users: [], businesses: [], requests: [] } });
    const results = await adminService.globalSearch(query);
    res.status(200).json({ success: true, data: results });
  } catch (err) {
    next(err);
  }
}

// --- Analytics ---
export async function getAnalytics(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await adminService.getAnalytics();
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
}

// --- Admin Settings & Profile ---
export async function getAdminProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await adminService.getAdminProfile(req.userId!);
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
}

export async function updateAdminProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await adminService.updateAdminProfile(req.userId!, req.body);
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
}

export async function getSettings(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await adminService.getSettings();
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
}

export async function updateSettings(req: Request, res: Response, next: NextFunction) {
  try {
    const data = await adminService.updateSettings(req.body);
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
}

// --- Users ---
export async function getAllUsers(req: Request, res: Response, next: NextFunction) {
  try {
    const users = await adminService.getAllUsers();
    res.status(200).json({ success: true, data: users });
  } catch (err) {
    next(err);
  }
}

export async function getUserById(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await adminService.getUserById(req.params.id as string);
    if (!user) return res.status(404).json({ success: false, message: "User not found" });
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

export async function updateUserRole(req: Request, res: Response, next: NextFunction) {
  try {
    const { role } = req.body;
    const user = await adminService.updateUserRole(req.params.id as string, role as Role);
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

export async function toggleUserVerification(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await adminService.toggleUserVerification(req.params.id as string);
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

export async function deleteUser(req: Request, res: Response, next: NextFunction) {
  try {
    await adminService.deleteUser(req.params.id as string);
    res.status(200).json({ success: true, message: "User deleted" });
  } catch (err) {
    next(err);
  }
}

// --- Businesses ---
export async function getAllBusinesses(req: Request, res: Response, next: NextFunction) {
  try {
    const businesses = await adminService.getAllBusinesses();
    res.status(200).json({ success: true, data: businesses });
  } catch (err) {
    next(err);
  }
}

export async function getBusinessById(req: Request, res: Response, next: NextFunction) {
  try {
    const business = await adminService.getBusinessById(req.params.id as string);
    if (!business) return res.status(404).json({ success: false, message: "Business not found" });
    res.status(200).json({ success: true, data: business });
  } catch (err) {
    next(err);
  }
}

export async function toggleBusinessVerification(req: Request, res: Response, next: NextFunction) {
  try {
    const business = await adminService.toggleBusinessVerification(req.params.id as string);
    res.status(200).json({ success: true, data: business });
  } catch (err) {
    next(err);
  }
}

export async function deleteBusiness(req: Request, res: Response, next: NextFunction) {
  try {
    await adminService.deleteBusiness(req.params.id as string);
    res.status(200).json({ success: true, message: "Business deleted" });
  } catch (err) {
    next(err);
  }
}

// --- Categories ---
export async function getAllCategories(req: Request, res: Response, next: NextFunction) {
  try {
    const categories = await adminService.getAllCategories();
    res.status(200).json({ success: true, data: categories });
  } catch (err) {
    next(err);
  }
}

export async function createCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { name, icon } = req.body;
    const category = await adminService.createCategory(name, icon);
    res.status(201).json({ success: true, data: category });
  } catch (err) {
    next(err);
  }
}

export async function updateCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { name, icon } = req.body;
    const category = await adminService.updateCategory(req.params.id as string, name, icon);
    res.status(200).json({ success: true, data: category });
  } catch (err) {
    next(err);
  }
}

export async function deleteCategory(req: Request, res: Response, next: NextFunction) {
  try {
    await adminService.deleteCategory(req.params.id as string);
    res.status(200).json({ success: true, message: "Category deleted" });
  } catch (err) {
    next(err);
  }
}

// --- Products ---
export async function getAllProducts(req: Request, res: Response, next: NextFunction) {
  try {
    const products = await adminService.getAllProducts();
    res.status(200).json({ success: true, data: products });
  } catch (err) {
    next(err);
  }
}

export async function deleteProduct(req: Request, res: Response, next: NextFunction) {
  try {
    await adminService.deleteProduct(req.params.id as string);
    res.status(200).json({ success: true, message: "Product deleted" });
  } catch (err) {
    next(err);
  }
}

// --- Services ---
export async function getAllServices(req: Request, res: Response, next: NextFunction) {
  try {
    const services = await adminService.getAllServices();
    res.status(200).json({ success: true, data: services });
  } catch (err) {
    next(err);
  }
}

export async function deleteService(req: Request, res: Response, next: NextFunction) {
  try {
    await adminService.deleteService(req.params.id as string);
    res.status(200).json({ success: true, message: "Service deleted" });
  } catch (err) {
    next(err);
  }
}

// --- Requests ---
export async function getAllRequests(req: Request, res: Response, next: NextFunction) {
  try {
    const requests = await adminService.getAllRequests();
    res.status(200).json({ success: true, data: requests });
  } catch (err) {
    next(err);
  }
}

export async function updateRequestStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const { status } = req.body;
    const request = await adminService.updateRequestStatus(req.params.id as string, status as RequestStatus);
    res.status(200).json({ success: true, data: request });
  } catch (err) {
    next(err);
  }
}

// --- Subscriptions ---
export async function getAllSubscriptions(req: Request, res: Response, next: NextFunction) {
  try {
    const subscriptions = await adminService.getAllSubscriptions();
    res.status(200).json({ success: true, data: subscriptions });
  } catch (err) {
    next(err);
  }
}

export async function getUserSubscriptions(req: Request, res: Response, next: NextFunction) {
  try {
    const userSubscriptions = await adminService.getUserSubscriptions();
    res.status(200).json({ success: true, data: userSubscriptions });
  } catch (err) {
    next(err);
  }
}

// --- Notifications ---
export async function getAllNotifications(req: Request, res: Response, next: NextFunction) {
  try {
    const notifications = await adminService.getAllNotifications();
    res.status(200).json({ success: true, data: notifications });
  } catch (err) {
    next(err);
  }
}

// --- Reports ---
export async function getAllReports(req: Request, res: Response, next: NextFunction) {
  try {
    const reports = await adminService.getAllReports();
    res.status(200).json({ success: true, data: reports });
  } catch (err) {
    next(err);
  }
}

export async function updateReportStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const { status } = req.body;
    const report = await adminService.updateReportStatus(req.params.id as string, status as ReportStatus);
    res.status(200).json({ success: true, data: report });
  } catch (err) {
    next(err);
  }
}

