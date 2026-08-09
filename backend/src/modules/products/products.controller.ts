import type { Request, Response, NextFunction } from "express";
import * as service from "./products.services.js";

export async function createProduct(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const { name, description, price, image } = req.body;
    const data: any = { name: String(name), price: parseFloat(price) };
    if (description !== undefined) data.description = String(description);
    if (image !== undefined) data.image = String(image);

    const product = await service.createProduct(userId, data);
    res.status(201).json({ success: true, data: product });
  } catch (err) {
    next(err);
  }
}

export async function getProducts(req: Request, res: Response, next: NextFunction) {
  try {
    const businessId = req.query.businessId as string;
    if (!businessId) {
      return res.status(400).json({ success: false, message: "businessId query parameter is required" });
    }
    const products = await service.getProducts(businessId);
    res.status(200).json({ success: true, data: products });
  } catch (err) {
    next(err);
  }
}

export async function updateProduct(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    const { name, description, price, image } = req.body;
    const data: any = {};
    if (name !== undefined) data.name = String(name);
    if (description !== undefined) data.description = String(description);
    if (price !== undefined) data.price = parseFloat(price);
    if (image !== undefined) data.image = String(image);

    const product = await service.updateProduct(userId, id, data);
    res.status(200).json({ success: true, data: product });
  } catch (err) {
    next(err);
  }
}

export async function deleteProduct(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;
    await service.deleteProduct(userId, id);
    res.status(200).json({ success: true, message: "Product deleted" });
  } catch (err) {
    next(err);
  }
}
