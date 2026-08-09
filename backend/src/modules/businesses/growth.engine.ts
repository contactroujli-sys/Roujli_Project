import { PrismaClient, NotificationType } from "@prisma/client";
import { sendNotification } from "../notifications/notifications.services.js";

const prisma = new PrismaClient();

export interface ScorePillar {
  name: string;
  key: string;
  score: number;
  maxScore: number;
  details: string[];
}

export interface GrowthScoreResult {
  growthScore: number;
  monthlyGrowth: number;
  breakdown: Record<string, number>;
  pillars: ScorePillar[];
}

export interface Recommendation {
  id: string;
  problem: string;
  reason: string;
  recommendation: string;
  expectedImpact: string;
  relatedMetric: string;
  actionType: string;
}

export interface GrowthTask {
  id: string;
  title: string;
  description: string;
  points: number;
  completed: boolean;
  actionRoute: string;
}

export interface Opportunity {
  id: string;
  title: string;
  type: "CUSTOMER" | "PARTNER" | "SERVICE_PROVIDER" | "COLLABORATION";
  businessId?: string;
  businessName?: string;
  category?: string;
  matchReason: string;
}

export async function evaluateBusinessGrowth(businessId: string): Promise<{
  scoreResult: GrowthScoreResult;
  recommendations: Recommendation[];
  tasks: GrowthTask[];
  opportunities: Opportunity[];
  metrics: {
    profileViews: number;
    productViews: number;
    serviceViews: number;
    interactions: number;
    conversionRate: string;
    responseTimeMins: number;
    responseRate: number;
    leads: number;
    reviewsCount: number;
    rating: number;
  };
}> {
  const business = await prisma.business.findUnique({
    where: { id: businessId },
    include: {
      category: true,
      owner: true,
      products: true,
      services: true,
      offers: true,
      requests: true,
      metrics: true,
      _count: {
        select: { followers: true, requests: true, savedBy: true }
      }
    }
  });

  if (!business) {
    throw new Error("Business not found");
  }

  // Fetch or initialize BusinessMetric with real baseline data (no arbitrary estimates)
  let metrics = business.metrics;
  if (!metrics) {
    metrics = await prisma.businessMetric.create({
      data: {
        businessId: business.id,
        profileViews: 0,
        productViews: 0,
        serviceViews: 0,
        totalInteractions: business._count.requests + (business._count.followers * 2),
        responseTimeMins: 0,
        responseRate: 0,
      }
    });
  }

  // 1. Profile Completeness (Max 20 pts)
  const hasLogo = Boolean(business.logo && business.logo.length > 0);
  const hasCover = Boolean(business.cover && business.cover.length > 0);
  const hasDescLong = Boolean(business.description && business.description.length >= 80);
  const hasDescShort = Boolean(business.description && business.description.length > 0);
  const hasAddress = Boolean(business.address && business.address.length > 0);
  const hasWebsite = Boolean(business.website && business.website.length > 0);
  const hasPhone = Boolean((business.phone && business.phone.length > 0) || (business.whatsapp && business.whatsapp.length > 0));

  let profileCompleteness = 0;
  const profileDetails: string[] = [];
  if (hasLogo) { profileCompleteness += 4; profileDetails.push("Logo uploaded (+4)"); }
  if (hasCover) { profileCompleteness += 3; profileDetails.push("Cover image set (+3)"); }
  if (hasDescLong) { profileCompleteness += 4; profileDetails.push("Detailed description (+4)"); }
  else if (hasDescShort) { profileCompleteness += 2; profileDetails.push("Basic description (+2)"); }
  if (hasAddress) { profileCompleteness += 3; profileDetails.push("Address specified (+3)"); }
  if (hasWebsite) { profileCompleteness += 3; profileDetails.push("Website linked (+3)"); }
  if (hasPhone) { profileCompleteness += 3; profileDetails.push("Contact info available (+3)"); }

  // 2. Catalog Depth (Max 20 pts)
  const productCount = business.products.length;
  const serviceCount = business.services.length;
  const offerCount = business.offers.length;
  const totalCatalogItems = productCount + serviceCount;

  let catalogDepth = 0;
  const catalogDetails: string[] = [];
  if (productCount > 0) { catalogDepth += 5; catalogDetails.push("Products listed (+5)"); }
  if (serviceCount > 0) { catalogDepth += 5; catalogDetails.push("Services offered (+5)"); }
  if (totalCatalogItems >= 3) { catalogDepth += 5; catalogDetails.push("Diverse catalog (+5)"); }
  if (offerCount > 0) { catalogDepth += 5; catalogDetails.push("Promotional offer active (+5)"); }

  // 3. Response Performance & Activity (Max 20 pts)
  const responseRate = metrics.responseRate;
  const responseTimeMins = metrics.responseTimeMins;
  const daysSinceUpdate = Math.floor((Date.now() - new Date(business.updatedAt).getTime()) / (1000 * 60 * 60 * 24));
  const isRecentlyActive = daysSinceUpdate <= 14;

  let responsePerformance = 0;
  const responseDetails: string[] = [];
  if (metrics.totalInteractions === 0 && responseTimeMins === 0 && responseRate === 0) {
    responseDetails.push("Insufficient data - response metrics will calculate after your first customer inquiry.");
  } else {
    if (responseRate >= 80) { responsePerformance += 8; responseDetails.push("High response rate >=80% (+8)"); }
    else if (responseRate >= 50) { responsePerformance += 4; responseDetails.push("Moderate response rate (+4)"); }

    if (responseTimeMins > 0 && responseTimeMins <= 60) { responsePerformance += 8; responseDetails.push("Fast response time <=60m (+8)"); }
    else if (responseTimeMins > 0 && responseTimeMins <= 180) { responsePerformance += 4; responseDetails.push("Acceptable response time (+4)"); }
  }
  if (isRecentlyActive) { responsePerformance += 4; responseDetails.push("Active within last 14 days (+4)"); }

  // 4. Customer Engagement & Leads (Max 15 pts)
  const totalViews = metrics.profileViews + metrics.productViews + metrics.serviceViews;
  const leadsCount = business._count.requests;
  const conversionRateVal = totalViews > 0 ? (leadsCount / totalViews) * 100 : 0;

  let customerEngagement = 0;
  const engagementDetails: string[] = [];
  if (totalViews === 0 && leadsCount === 0 && business._count.followers === 0) {
    engagementDetails.push("Insufficient data - interaction metrics will update when visitors view or contact your business.");
  } else {
    if (conversionRateVal >= 3.0 || leadsCount >= 5) { customerEngagement += 5; engagementDetails.push("Good view-to-lead conversion (+5)"); }
    else if (conversionRateVal >= 1.0) { customerEngagement += 3; engagementDetails.push("Baseline conversion (+3)"); }

    if (leadsCount >= 3) { customerEngagement += 5; engagementDetails.push("Handled 3+ customer leads (+5)"); }
    else if (leadsCount > 0) { customerEngagement += 2; engagementDetails.push("Received customer inquiry (+2)"); }

    if (business._count.followers >= 5) { customerEngagement += 5; engagementDetails.push("Follower network >=5 (+5)"); }
    else if (business._count.followers > 0) { customerEngagement += 2; engagementDetails.push("Building follower base (+2)"); }
  }

  // 5. Satisfaction & Reputation (Max 15 pts)
  let reputation = 0;
  const reputationDetails: string[] = [];
  if (business.reviews === 0) {
    reputationDetails.push("Not enough data yet - customer reviews will update score when received.");
  } else {
    if (business.rating >= 4.5) { reputation += 5; reputationDetails.push("Excellent rating >=4.5 (+5)"); }
    else if (business.rating >= 4.0) { reputation += 3; reputationDetails.push("Good rating >=4.0 (+3)"); }

    if (business.reviews >= 5) { reputation += 5; reputationDetails.push("Solid review count >=5 (+5)"); }
    else if (business.reviews > 0) { reputation += 2; reputationDetails.push("First customer reviews (+2)"); }
  }

  if (business.verified) { reputation += 5; reputationDetails.push("Verified business badge (+5)"); }

  // 6. Trust & Verification (Max 10 pts)
  let trustVerification = 0;
  const trustDetails: string[] = [];
  if (business.owner.isVerified) { trustVerification += 5; trustDetails.push("Owner identity verified (+5)"); }
  if (hasPhone && (business.email || business.owner.email)) { trustVerification += 5; trustDetails.push("Multi-channel contact verified (+5)"); }

  const totalScore = Math.min(100, Math.max(0,
    profileCompleteness + catalogDepth + responsePerformance + customerEngagement + reputation + trustVerification
  ));

  const monthlyGrowth = totalScore - business.growthScore;

  // Persist calculated score if updated
  if (business.growthScore !== totalScore) {
    const oldScore = business.growthScore;
    await prisma.business.update({
      where: { id: business.id },
      data: {
        growthScore: totalScore,
        monthlyGrowth: monthlyGrowth !== 0 ? monthlyGrowth : business.monthlyGrowth
      }
    });

    if (Math.abs(totalScore - oldScore) >= 5) {
          await sendNotification({
            userId: business.ownerId,
            type: NotificationType.GROWTH_SCORE_CHANGED,
            title: "Your Growth Score changed",
            body: `Your Growth Score ${totalScore > oldScore ? "increased" : "changed"} to ${totalScore}.`,
            data: {
              type: "growth_score_changed",
              oldScore,
              newScore: totalScore,
            },
          });
    }

    // Save history snapshot if missing for today
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const existingToday = await prisma.growthHistory.findFirst({
      where: {
        businessId: business.id,
        recordedAt: { gte: startOfDay }
      }
    });

    if (!existingToday) {
      await prisma.growthHistory.create({
        data: {
          businessId: business.id,
          score: totalScore,
          breakdown: {
            profileCompleteness,
            catalogDepth,
            responsePerformance,
            customerEngagement,
            reputation,
            trustVerification
          }
        }
      });
    }
  }

  // Build Score Breakdown Pillars
  const pillars: ScorePillar[] = [
    { name: "Profile Completeness", key: "profileCompleteness", score: profileCompleteness, maxScore: 20, details: profileDetails },
    { name: "Products & Services", key: "catalogDepth", score: catalogDepth, maxScore: 20, details: catalogDetails },
    { name: "Response Performance", key: "responsePerformance", score: responsePerformance, maxScore: 20, details: responseDetails },
    { name: "Customer Engagement", key: "customerEngagement", score: customerEngagement, maxScore: 15, details: engagementDetails },
    { name: "Customer Satisfaction", key: "reputation", score: reputation, maxScore: 15, details: reputationDetails },
    { name: "Trust & Verification", key: "trustVerification", score: trustVerification, maxScore: 10, details: trustDetails },
  ];

  // ─── Generate Dynamic Personalized Recommendations (Analyze -> Score -> Diagnose -> Recommend -> Match -> Act) ───
  const recommendations: Recommendation[] = [];

  // Diagnosis 1: Profile Completeness
  if (profileCompleteness < 16) {
    recommendations.push({
      id: "rec-profile-completeness",
      problem: "Incomplete business profile details.",
      reason: "Complete profiles provide clear visibility and build customer confidence.",
      recommendation: "Complete your business profile details",
      expectedImpact: "Impact: Improve profile completeness and strengthen customer trust signals.",
      relatedMetric: "Profile Completion",
      actionType: "COMPLETE_PROFILE"
    });
  }

  // Diagnosis 2: Catalog Depth
  if (totalCatalogItems === 0) {
    recommendations.push({
      id: "rec-add-catalog",
      problem: "Your business has no active products or services listed.",
      reason: "Customers cannot send inquiries or requests without active catalog items.",
      recommendation: "Add your first product or service offering",
      expectedImpact: "Impact: Unlock direct customer requests and build your catalog.",
      relatedMetric: "Products & Services",
      actionType: "ADD_PRODUCT"
    });
  } else if (productCount > 0 && serviceCount === 0) {
    recommendations.push({
      id: "rec-add-service",
      problem: "You have products listed but no service offerings.",
      reason: "Service offerings expand your potential client reach.",
      recommendation: "Add your first service offering",
      expectedImpact: "Impact: Expand catalog offerings and attract service-focused clients.",
      relatedMetric: "Services Catalog",
      actionType: "ADD_SERVICE"
    });
  }

  // Diagnosis 3: Traffic vs Engagement (High views, low engagement / inquiries)
  if (totalViews > 10 && conversionRateVal < 2.0) {
    recommendations.push({
      id: "rec-improve-descriptions",
      problem: "High profile views but low customer interaction.",
      reason: "Visitors are browsing your business page but not initiating requests.",
      recommendation: "Improve product & service presentation with clear details and images",
      expectedImpact: "Impact: Improve visitor engagement and inquiry conversion rate.",
      relatedMetric: "Customer Engagement",
      actionType: "IMPROVE_DESCRIPTION"
    });
  }

  // Diagnosis 4: Response Performance & Speed
  if (responseTimeMins > 60 || (responseRate < 80 && metrics.totalInteractions > 0)) {
    recommendations.push({
      id: "rec-response-time",
      problem: "Sub-optimal customer response speed or rate.",
      reason: "Delayed responses reduce customer conversion and impact business score.",
      recommendation: "Improve response performance by answering inquiries promptly",
      expectedImpact: "Impact: Enhance response performance and improve customer satisfaction.",
      relatedMetric: "Response Performance",
      actionType: "IMPROVE_RESPONSE"
    });
  }

  // Diagnosis 5: Business Verification
  if (!business.verified) {
    recommendations.push({
      id: "rec-get-verified",
      problem: "Your business profile is unverified.",
      reason: "Verified businesses earn trust badges and priority search placement.",
      recommendation: "Submit business verification documents",
      expectedImpact: "Impact: Obtain official verification badge and enhance business visibility.",
      relatedMetric: "Business Verification",
      actionType: "VERIFY_BUSINESS"
    });
  }

  // ─── Generate Actionable Tasks ─────────────────────────────────────────────
  const tasks: GrowthTask[] = [
    {
      id: "task-logo",
      title: "Upload Business Logo & Cover",
      description: "Present a professional brand image with a logo and high-quality cover photo.",
      points: 7,
      completed: hasLogo && hasCover,
      actionRoute: "/settings/profile"
    },
    {
      id: "task-desc",
      title: "Write Detailed Business Description",
      description: "Provide at least 80 characters describing your offerings and core value.",
      points: 4,
      completed: hasDescLong,
      actionRoute: "/settings/profile"
    },
    {
      id: "task-catalog",
      title: "Add Products & Services",
      description: "List your core products or service offerings for clients.",
      points: 10,
      completed: totalCatalogItems >= 2,
      actionRoute: "/products/create"
    },
    {
      id: "task-offer",
      title: "Create a Promotional Offer",
      description: "Publish a discount or seasonal offer to attract new customers.",
      points: 5,
      completed: offerCount > 0,
      actionRoute: "/offers/create"
    },
    {
      id: "task-contact",
      title: "Configure Direct WhatsApp / Phone Contact",
      description: "Enable direct messaging options for quick customer inquiries.",
      points: 3,
      completed: hasPhone,
      actionRoute: "/settings/contact"
    },
    {
      id: "task-reviews",
      title: "Gather Customer Reviews",
      description: "Deliver excellent service and reach at least 5 customer reviews.",
      points: 5,
      completed: business.reviews >= 5,
      actionRoute: "/requests"
    }
  ];

  // ─── Deterministic Opportunity Matching ───────────────────────────────────
  const opportunities: Opportunity[] = [];

  // Match 1: Complementary service providers in other categories
  const providers = await prisma.business.findMany({
    where: {
      id: { not: business.id },
      verified: true
    },
    take: 3,
    include: { category: true }
  });

  for (const p of providers) {
    if (p.categoryId !== business.categoryId) {
      opportunities.push({
        id: `opp-provider-${p.id}`,
        title: `Partner with ${p.name}`,
        type: "PARTNER",
        businessId: p.id,
        businessName: p.name,
        category: p.category.name,
        matchReason: `Verified provider in ${p.category.name} available for cross-promotion.`
      });
    }
  }

  // Match 2: B2B Service Opportunity
  if (business.category.name === "Food & Beverage") {
    opportunities.push({
      id: "opp-needs-marketing",
      title: "Digital Marketing & Branding Expert",
      type: "SERVICE_PROVIDER",
      matchReason: "Boost local visibility and online customer orders for your restaurant."
    });
  } else if (business.category.name === "Health & Wellness") {
    opportunities.push({
      id: "opp-needs-logistics",
      title: "Corporate Wellness Collaboration",
      type: "COLLABORATION",
      matchReason: "Offer packages to corporate clients seeking employee health benefits."
    });
  } else if (business.category.name === "Technology Services") {
    opportunities.push({
      id: "opp-needs-b2b",
      title: "Enterprise Client Lead Network",
      type: "CUSTOMER",
      matchReason: "Local SME businesses seeking IT auditing and cloud migration."
    });
  }

  return {
    scoreResult: {
      growthScore: totalScore,
      monthlyGrowth,
      breakdown: {
        profileCompleteness,
        catalogDepth,
        responsePerformance,
        customerEngagement,
        reputation,
        trustVerification
      },
      pillars
    },
    recommendations,
    tasks,
    opportunities,
    metrics: {
      profileViews: metrics.profileViews,
      productViews: metrics.productViews,
      serviceViews: metrics.serviceViews,
      interactions: metrics.totalInteractions,
      conversionRate: `${conversionRateVal.toFixed(1)}%`,
      responseTimeMins: metrics.responseTimeMins,
      responseRate: metrics.responseRate,
      leads: leadsCount,
      reviewsCount: business.reviews,
      rating: business.rating
    }
  };
}
