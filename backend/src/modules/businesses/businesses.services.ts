import * as repo from "./businesses.repository.js";
import { updateBusinessData } from "../profiles/profiles.repository.js";
import type { BusinessListQuery } from "./businesses.types.js";
import { PrismaClient } from "@prisma/client";
import { evaluateBusinessGrowth } from "./growth.engine.js";

const prisma = new PrismaClient();

export async function createBusiness(userId: string, data: any) {
  return updateBusinessData(userId, data);
}

export async function getBusinesses(query: BusinessListQuery, userId?: string) {
  return repo.listBusinesses(query, userId);
}

export async function getSearchSuggestions(query: string) {
  return repo.getSearchSuggestions(query);
}

export async function getBusinessById(id: string, userId?: string) {
  return repo.getBusinessById(id, userId);
}

export async function toggleSave(userId: string, businessId: string) {
  return repo.toggleSaveBusiness(userId, businessId);
}

export async function toggleFollow(userId: string, businessId: string) {
  return repo.toggleFollowBusiness(userId, businessId);
}

export async function getSaved(userId: string) {
  return repo.getSavedBusinesses(userId);
}

export async function getGrowthDetails(userId: string) {
  const business = await prisma.business.findUnique({
    where: { ownerId: userId },
    select: { id: true, name: true }
  });

  if (!business) {
    throw new Error("Business not found for this user");
  }

  const evaluation = await evaluateBusinessGrowth(business.id);

  return {
    businessId: business.id,
    businessName: business.name,
    growthScore: evaluation.scoreResult.growthScore,
    monthlyGrowth: evaluation.scoreResult.monthlyGrowth,
    breakdown: evaluation.scoreResult.breakdown,
    pillars: evaluation.scoreResult.pillars,
    recommendations: evaluation.recommendations,
    tasks: evaluation.tasks,
    opportunities: evaluation.opportunities,
    metrics: evaluation.metrics
  };
}

export async function getGrowthHistory(userId: string) {
  const business = await prisma.business.findUnique({
    where: { ownerId: userId },
    select: { id: true }
  });

  if (!business) {
    throw new Error("Business not found for this user");
  }

  const history = await prisma.growthHistory.findMany({
    where: { businessId: business.id },
    orderBy: { recordedAt: "asc" },
    take: 30
  });

  return history.map(h => ({
    id: h.id,
    score: h.score,
    breakdown: h.breakdown,
    recordedAt: h.recordedAt
  }));
}

