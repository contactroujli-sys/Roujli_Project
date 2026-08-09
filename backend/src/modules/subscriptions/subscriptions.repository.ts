import { PrismaClient, SubscriptionType } from "@prisma/client";

const prisma = new PrismaClient();

export const DEFAULT_PLANS = [
  {
    type: SubscriptionType.START,
    name: "START",
    price: 0,
    currency: "DZD",
    suitableFor: "Platform discovery & initial presence",
    maxProducts: 5,
    maxServices: 5,
    maxOffers: 1,
    priority: 1,
    verifiedBadge: false,
    hasAnalytics: false,
    hasGrowthEngine: false,
    hasAI: false,
    hasB2B: false,
    isCustomPrice: false,
    features: [
      "Business Profile Page",
      "Limited Products & Services",
      "Search Visibility",
      "Receive Customer Inquiries",
      "Basic Indicators",
    ],
  },
  {
    type: SubscriptionType.GROW,
    name: "GROW",
    price: 2500,
    currency: "DZD",
    suitableFor: "Business owners & small enterprises",
    maxProducts: 25,
    maxServices: 25,
    maxOffers: 5,
    priority: 2,
    verifiedBadge: false,
    hasAnalytics: true,
    hasGrowthEngine: true,
    hasAI: false,
    hasB2B: false,
    isCustomPrice: false,
    features: [
      "All START Features",
      "Expanded Products & Services",
      "Performance Analytics",
      "Growth Score System",
      "Basic Growth Recommendations",
      "Active Promotional Offers",
      "Advanced Communication Tools",
    ],
  },
  {
    type: SubscriptionType.SCALE,
    name: "SCALE",
    price: 5000,
    currency: "DZD",
    suitableFor: "Active enterprises needing growth tools",
    maxProducts: 100,
    maxServices: 100,
    maxOffers: 20,
    priority: 3,
    verifiedBadge: true,
    hasAnalytics: true,
    hasGrowthEngine: true,
    hasAI: true,
    hasB2B: true,
    isCustomPrice: false,
    features: [
      "All GROW Features",
      "Advanced Analytics",
      "AI Recommendations Engine",
      "Business Performance Analysis",
      "Matches & Partnerships",
      "Growth Reports",
      "Additional AI Tools",
    ],
  },
  {
    type: SubscriptionType.ENTERPRISE,
    name: "ENTERPRISE",
    price: 15000,
    currency: "DZD",
    suitableFor: "Companies & corporations",
    maxProducts: 9999,
    maxServices: 9999,
    maxOffers: 999,
    priority: 4,
    verifiedBadge: true,
    hasAnalytics: true,
    hasGrowthEngine: true,
    hasAI: true,
    hasB2B: true,
    isCustomPrice: true,
    features: [
      "Custom Enterprise Solutions",
      "Dedicated Dashboard",
      "B2B Solutions",
      "API & Integrations",
      "Advanced Reporting",
      "Dedicated Support",
    ],
  },
];

export const DEFAULT_ADDONS = [
  {
    name: "AI Premium",
    description: "Access advanced AI strategic generation, predictive growth tools, and personalized market insights.",
    price: 1500,
    currency: "DZD",
    category: "AI",
    icon: "psychology",
  },
  {
    name: "Advanced Analytics",
    description: "Deep dive into customer traffic, conversion funnels, catalog performance, and growth score trends.",
    price: 990,
    currency: "DZD",
    category: "ANALYTICS",
    icon: "bar_chart",
  },
  {
    name: "Professional Performance Reports",
    description: "Export comprehensive PDF/Excel executive reports detailing business performance and benchmarks.",
    price: 750,
    currency: "DZD",
    category: "REPORTING",
    icon: "summarize",
  },
  {
    name: "Business Verification Badge",
    description: "Earn the official ROUJLI Verified Badge to boost customer trust and increase search placement.",
    price: 1200,
    currency: "DZD",
    category: "VERIFICATION",
    icon: "verified",
  },
  {
    name: "Featured Search Placement",
    description: "Promote your business profile to the top of category search results and homepage recommendations.",
    price: 1990,
    currency: "DZD",
    category: "MARKETING",
    icon: "star",
  },
  {
    name: "Premium Promotional Campaigns",
    description: "Run targeted promotional campaigns for your offers and products across the ecosystem.",
    price: 2490,
    currency: "DZD",
    category: "MARKETING",
    icon: "campaign",
  },
  {
    name: "Custom Enterprise Solutions",
    description: "Tailored integrations, multi-branch management, custom API access, and dedicated consulting.",
    price: null,
    currency: "DZD",
    category: "ENTERPRISE",
    icon: "corporate_fare",
  },
];

export async function ensurePlansAndAddonsSeeded() {
  try {
    // 1. Upsert official 4 plans first
    for (const plan of DEFAULT_PLANS) {
      await prisma.subscriptionPlan.upsert({
        where: { type: plan.type },
        update: plan,
        create: plan,
      });
    }

    // 2. Reassign userSubscriptions linked to legacy plans (FREE, PLUS, PREMIUM) to START plan before deletion
    const startPlan = await prisma.subscriptionPlan.findUnique({
      where: { type: SubscriptionType.START },
    });

    if (startPlan) {
      const legacyPlans = await prisma.subscriptionPlan.findMany({
        where: {
          type: {
            notIn: [SubscriptionType.START, SubscriptionType.GROW, SubscriptionType.SCALE, SubscriptionType.ENTERPRISE]
          }
        },
        select: { id: true }
      });

      const legacyIds = legacyPlans.map(p => p.id);
      if (legacyIds.length > 0) {
        await prisma.userSubscription.updateMany({
          where: { planId: { in: legacyIds } },
          data: { planId: startPlan.id }
        });

        await prisma.subscriptionPlan.deleteMany({
          where: { id: { in: legacyIds } }
        });
      }
    }

    // 3. Upsert add-ons
    for (const addon of DEFAULT_ADDONS) {
      await prisma.addOnService.upsert({
        where: { name: addon.name },
        update: addon,
        create: addon,
      });
    }
  } catch (err) {
    console.error("[Seeding Subscriptions Warning]", err);
  }
}

export async function getSubscriptionPlans() {
  await ensurePlansAndAddonsSeeded();
  return prisma.subscriptionPlan.findMany({
    where: {
      type: {
        in: [SubscriptionType.START, SubscriptionType.GROW, SubscriptionType.SCALE, SubscriptionType.ENTERPRISE]
      }
    },
    orderBy: { priority: "asc" },
  });
}

export async function getAddOnServices() {
  await ensurePlansAndAddonsSeeded();
  return prisma.addOnService.findMany({
    orderBy: { name: "asc" },
  });
}

export async function getUserSubscription(userId: string) {
  const activeSub = await prisma.userSubscription.findFirst({
    where: { userId, status: "ACTIVE" },
    include: { plan: true },
    orderBy: { createdAt: "desc" },
  });

  if (activeSub) return activeSub;

  // Default to START plan
  const startPlan = await prisma.subscriptionPlan.findUnique({
    where: { type: SubscriptionType.START },
  });

  if (!startPlan) return null;

  return prisma.userSubscription.create({
    data: {
      userId,
      planId: startPlan.id,
      status: "ACTIVE",
    },
    include: { plan: true },
  });
}

export async function subscribeUserToPlan(userId: string, planType: SubscriptionType) {
  const plan = await prisma.subscriptionPlan.findUnique({
    where: { type: planType },
  });

  if (!plan) throw new Error("Invalid subscription plan");

  // Deactivate existing active subscriptions
  await prisma.userSubscription.updateMany({
    where: { userId, status: "ACTIVE" },
    data: { status: "EXPIRED" },
  });

  return prisma.userSubscription.create({
    data: {
      userId,
      planId: plan.id,
      status: "ACTIVE",
    },
    include: { plan: true },
  });
}
