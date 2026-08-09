import { SubscriptionType } from "@prisma/client";
import * as repo from "./subscriptions.repository.js";

export async function getPlans() {
  return repo.getSubscriptionPlans();
}

export async function getAddOns() {
  return repo.getAddOnServices();
}

export async function getMySubscription(userId: string) {
  return repo.getUserSubscription(userId);
}

export async function subscribeToPlan(userId: string, planType: SubscriptionType) {
  return repo.subscribeUserToPlan(userId, planType);
}
