import { Router } from "express";
import { PrismaClient } from "@prisma/client";

const router = Router();
const prisma = new PrismaClient();

const DEFAULT_CATEGORIES = [
  { name: "Tech & Electronics", icon: "laptop" },
  { name: "Fashion & Clothing", icon: "checkroom" },
  { name: "Food & Restaurants", icon: "restaurant" },
  { name: "Beauty & Health", icon: "spa" },
  { name: "Services & Crafts", icon: "build" },
  { name: "Automotive", icon: "directions_car" },
  { name: "Home & Furniture", icon: "chair" },
];

router.get("/", async (_req, res, next) => {
  try {
    let categories = await prisma.category.findMany({
      orderBy: { name: "asc" },
    });

    if (categories.length === 0) {
      await prisma.category.createMany({
        data: DEFAULT_CATEGORIES,
        skipDuplicates: true,
      });
      categories = await prisma.category.findMany({
        orderBy: { name: "asc" },
      });
    }

    res.status(200).json({
      success: true,
      data: categories,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
