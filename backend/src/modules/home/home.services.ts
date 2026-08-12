import { PrismaClient } from "@prisma/client";
import type { HomeData, Business as HomeBusiness, Offer as HomeOffer, Category as HomeCategory, Stat, BusinessInsight as HomeBusinessInsight } from "./home.types.js";
import { evaluateBusinessGrowth } from "../businesses/growth.engine.js";

const prisma = new PrismaClient();

// ─── Get Home Data ─────────────────────────────────────────────────────────

export async function getHomeData(userId?: string): Promise<HomeData> {
  const [
    dbCategories,
    totalBusinessesCount,
    dbTrending,
    dbRecommended,
    dbGrowing,
    dbOffers,
    dbInsights,
  ] = await Promise.all([
    prisma.category.findMany({
      include: {
        _count: {
          select: { businesses: true }
        }
      }
    }),
    prisma.business.count(),
    prisma.business.findMany({
      take: 5,
      orderBy: [
        { rating: 'desc' },
        { reviews: 'desc' }
      ],
      include: { category: true }
    }),
    prisma.business.findMany({
      take: 5,
      where: { verified: true },
      orderBy: { reviews: 'desc' },
      include: { category: true }
    }),
    prisma.business.findMany({
      take: 5,
      orderBy: { growthScore: 'desc' },
      include: { category: true }
    }),
    prisma.offer.findMany({
      take: 5,
      include: { business: true },
      orderBy: { createdAt: 'desc' }
    }),
    prisma.businessInsight.findMany({
      take: 5,
      orderBy: { createdAt: 'desc' }
    })
  ]);

  const categories: HomeCategory[] = dbCategories.map(cat => ({
    id: cat.id,
    name: cat.name,
    icon: cat.icon || "storefront",
    businessCount: cat._count.businesses
  }));

  // Add the "All" category at the beginning
  categories.unshift({
    id: "all",
    name: "All",
    icon: "all",
    businessCount: totalBusinessesCount
  });

  const trendingBusinesses: HomeBusiness[] = dbTrending.map(b => ({
    id: b.id,
    name: b.name,
    category: b.category?.name || "Business",
    imageUrl: b.logo || undefined,
    rating: b.rating,
    reviews: b.reviews,
    location: b.address || "Unknown Location",
    isVerified: b.verified
  }));

  const recommendedBusinesses: HomeBusiness[] = dbRecommended.map(b => ({
    id: b.id,
    name: b.name,
    category: b.category?.name || "Business",
    imageUrl: b.logo || undefined,
    rating: b.rating,
    reviews: b.reviews,
    location: b.address || "Unknown Location",
    isVerified: b.verified
  }));

  const growingBusinesses: HomeBusiness[] = dbGrowing.map(b => ({
    id: b.id,
    name: b.name,
    category: b.category?.name || "Business",
    imageUrl: b.logo || undefined,
    rating: b.rating,
    reviews: b.reviews,
    location: b.address || "Unknown Location",
    isVerified: b.verified
  }));

  const trendingOffers: HomeOffer[] = dbOffers.map(o => ({
    id: o.id,
    title: o.title,
    businessName: o.business?.name || "Business",
    imageUrl: o.image || undefined,
    discount: o.discount ? `${o.discount}% OFF` : "SPECIAL OFFER",
    description: o.description || "",
    expiresAt: o.expiresAt || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  }));

  const businessInsights: HomeBusinessInsight[] = dbInsights.length > 0
    ? dbInsights.map(i => ({
        id: i.id,
        title: i.title,
        description: i.description,
        category: i.category,
        createdAt: i.createdAt,
      }))
    : [
        {
          id: "tip-1",
          title: "Complete your business profile",
          description: "Businesses with complete profiles build higher customer trust and visibility.",
          category: "Growth",
          createdAt: new Date(),
        },
        {
          id: "tip-2",
          title: "Respond quickly to requests",
          description: "A fast response time increases your growth score and ranking.",
          category: "Engagement",
          createdAt: new Date(),
        },
      ];

  // 7. Growth Score & Stats for current user
  let growthScore = {
    score: 0,
    change: 0,
    period: "month"
  };

  let stats: Stat[] = [
    {
      label: "Total Views",
      value: "0",
      change: "0%",
      isPositive: true
    },
    {
      label: "Leads",
      value: "0",
      change: "0%",
      isPositive: true
    },
    {
      label: "Revenue",
      value: "$0",
      change: "0%",
      isPositive: true
    }
  ];

  if (userId) {
    const userBusiness = await prisma.business.findUnique({
      where: { ownerId: userId }
    });

    if (userBusiness) {
      const evalRes = await evaluateBusinessGrowth(userBusiness.id);
      growthScore = {
        score: evalRes.scoreResult.growthScore,
        change: evalRes.scoreResult.monthlyGrowth,
        period: "month"
      };

      // Calculate stats based on requests
      const leads = await prisma.request.count({
        where: { businessId: userBusiness.id }
      });

      // Sum of prices for ACCEPTED requests
      const acceptedRequests = await prisma.request.findMany({
        where: {
          businessId: userBusiness.id,
          status: 'ACCEPTED'
        },
        include: {
          product: true,
          service: true,
          offer: true
        }
      });

      let revenue = 0;
      for (const req of acceptedRequests) {
        let price = 0;
        if (req.product) price = req.product.price;
        else if (req.service) price = req.service.price;
        else if (req.offer && req.offer.discount) {
          price = req.offer.discount;
        }
        revenue += price * (req.quantity || 1);
      }

      const userMetrics = await prisma.businessMetric.findUnique({
        where: { businessId: userBusiness.id }
      });

      const actualViews = userMetrics
        ? userMetrics.profileViews + userMetrics.productViews + userMetrics.serviceViews
        : 0;

      stats = [
        {
          label: "Total Views",
          value: actualViews >= 1000 ? `${(actualViews / 1000).toFixed(1)}K` : `${actualViews}`,
          change: actualViews > 0 ? "Tracked" : "No views yet",
          isPositive: actualViews > 0
        },
        {
          label: "Leads",
          value: `${leads}`,
          change: leads > 0 ? "Active" : "No leads yet",
          isPositive: leads > 0
        },
        {
          label: "Revenue",
          value: revenue >= 1000 ? `${(revenue / 1000).toFixed(1)}K DZD` : `${revenue} DZD`,
          change: revenue > 0 ? "Recorded" : "No sales yet",
          isPositive: revenue > 0
        }
      ];
    }
  }

  return {
    growthScore,
    stats,
    trendingBusinesses,
    recommendedBusinesses,
    trendingOffers,
    growingBusinesses,
    businessInsights,
    categories
  };
}
