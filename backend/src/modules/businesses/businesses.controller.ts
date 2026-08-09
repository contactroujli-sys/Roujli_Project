import type { Request, Response, NextFunction } from "express";
import * as service from "./businesses.services.js";

export async function createBusiness(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const business = await service.createBusiness(userId, req.body);
    res.status(201).json({
      success: true,
      data: business,
    });
  } catch (err) {
    next(err);
  }
}

export async function getBusinesses(req: Request, res: Response, next: NextFunction) {
  try {
    const { search, categoryId, sort, page, limit } = req.query;
    const userId = req.userId;

    const result = await service.getBusinesses(
      {
        search: search as string,
        categoryId: categoryId as string,
        sort: sort as any,
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
      },
      userId
    );

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function getBusinessById(req: Request, res: Response, next: NextFunction) {
  try {
    const id = req.params.id as string;
    const userId = req.userId;

    const business = await service.getBusinessById(id, userId);

    if (!business) {
      return res.status(404).json({
        success: false,
        message: "Business not found",
      });
    }

    res.status(200).json({
      success: true,
      data: business,
    });
  } catch (err) {
    next(err);
  }
}

export async function toggleSave(req: Request, res: Response, next: NextFunction) {
  try {
    const id = req.params.id as string;
    const userId = req.userId!;

    const result = await service.toggleSave(userId, id);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function toggleFollow(req: Request, res: Response, next: NextFunction) {
  try {
    const id = req.params.id as string;
    const userId = req.userId!;

    const result = await service.toggleFollow(userId, id);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function getSaved(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;

    const saved = await service.getSaved(userId);

    res.status(200).json({
      success: true,
      data: saved,
    });
  } catch (err) {
    next(err);
  }
}

export async function getGrowthDetails(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const growthInfo = await service.getGrowthDetails(userId);
    res.status(200).json({
      success: true,
      data: growthInfo,
    });
  } catch (err) {
    next(err);
  }
}

export async function getGrowthHistory(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId!;
    const history = await service.getGrowthHistory(userId);
    res.status(200).json({
      success: true,
      data: history,
    });
  } catch (err) {
    next(err);
  }
}

