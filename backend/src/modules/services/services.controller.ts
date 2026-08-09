import type { Request, Response, NextFunction } from "express";
import * as service from "./services.services.js";

export async function createService(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const { name, description, price, duration, image } = req.body;
    const data: any = { name: String(name), price: parseFloat(price) };
    if (description !== undefined) data.description = String(description);
    if (duration !== undefined) data.duration = parseInt(duration);
    if (image !== undefined) data.image = String(image);

    const item = await service.createService(userId, data);
    res.status(201).json({ success: true, data: item });
  } catch (err) {
    next(err);
  }
}

export async function getServices(req: Request, res: Response, next: NextFunction) {
  try {
    const businessId = req.query.businessId as string;
    if (!businessId) {
      return res.status(400).json({ success: false, message: "businessId query parameter is required" });
    }
    const services = await service.getServices(businessId);
    res.status(200).json({ success: true, data: services });
  } catch (err) {
    next(err);
  }
}

export async function updateService(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    const { name, description, price, duration, image } = req.body;
    const data: any = {};
    if (name !== undefined) data.name = String(name);
    if (description !== undefined) data.description = String(description);
    if (price !== undefined) data.price = parseFloat(price);
    if (duration !== undefined) data.duration = parseInt(duration);
    if (image !== undefined) data.image = String(image);

    const item = await service.updateService(userId, id, data);
    res.status(200).json({ success: true, data: item });
  } catch (err) {
    next(err);
  }
}

export async function deleteService(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    await service.deleteService(userId, id);
    res.status(200).json({ success: true, message: "Service deleted" });
  } catch (err) {
    next(err);
  }
}
