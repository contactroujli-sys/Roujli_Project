import { PrismaClient } from "@prisma/client";
import type { BusinessListQuery } from "./businesses.types.js";

const prisma = new PrismaClient();

export async function listBusinesses(query: BusinessListQuery, currentUserId?: string) {
  const { search, categoryId, sort = "newest", page = 1, limit = 20 } = query;
  const skip = (page - 1) * limit;

  const andConditions: any[] = [];

  if (search && search.trim().length > 0) {
    const s = search.trim();
    andConditions.push({
      OR: [
        { name: { contains: s, mode: "insensitive" } },
        { description: { contains: s, mode: "insensitive" } },
        { category: { name: { contains: s, mode: "insensitive" } } },
        { products: { some: { name: { contains: s, mode: "insensitive" } } } },
        { services: { some: { name: { contains: s, mode: "insensitive" } } } },
        { offers: { some: { title: { contains: s, mode: "insensitive" } } } },
      ],
    });
  }

  if (categoryId && categoryId !== "0" && categoryId !== "All") {
    const cat = categoryId.trim();
    andConditions.push({
      OR: [
        { categoryId: cat },
        { category: { id: cat } },
        { category: { name: { equals: cat, mode: "insensitive" } } },
        { category: { name: { contains: cat, mode: "insensitive" } } },
      ],
    });
  }

  const where: any = andConditions.length > 0 ? { AND: andConditions } : {};

  let orderBy: any = { createdAt: "desc" };
  if (sort === "rating") orderBy = { rating: "desc" };
  if (sort === "growth") orderBy = { growthScore: "desc" };

  const [businesses, total] = await Promise.all([
    prisma.business.findMany({
      where,
      orderBy,
      skip,
      take: limit,
      include: {
        category: true,
        _count: {
          select: { followers: true },
        },
        savedBy: currentUserId ? { where: { userId: currentUserId } } : false,
        followers: currentUserId ? { where: { userId: currentUserId } } : false,
      },
    }),
    prisma.business.count({ where }),
  ]);

  const items = businesses.map((b: any) => ({
    id: b.id,
    name: b.name,
    slug: b.slug,
    description: b.description,
    logo: b.logo,
    cover: b.cover,
    category: b.category.name,
    location: b.address,
    rating: b.rating ?? 0.0,
    reviews: b.reviews ?? 0,
    growthScore: b.growthScore ?? 0,
    monthlyGrowth: b.monthlyGrowth ?? 0,
    verified: b.verified ?? false,
    followersCount: b._count?.followers ?? 0,
    isSaved: currentUserId && Array.isArray(b.savedBy) ? b.savedBy.length > 0 : false,
    isFollowed: currentUserId && Array.isArray(b.followers) ? b.followers.length > 0 : false,
  }));

  return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getBusinessById(id: string, currentUserId?: string) {
  const b: any = await prisma.business.findUnique({
    where: { id },
    include: {
      category: true,
      products: true,
      services: true,
      offers: true,
      _count: {
        select: { followers: true, products: true, services: true, offers: true },
      },
      savedBy: currentUserId ? { where: { userId: currentUserId } } : false,
      followers: currentUserId ? { where: { userId: currentUserId } } : false,
    },
  });

  if (!b) return null;

  return {
    id: b.id,
    name: b.name,
    slug: b.slug,
    description: b.description,
    logo: b.logo,
    cover: b.cover,
    phone: b.phone,
    email: b.email,
    website: b.website,
    whatsapp: b.whatsapp,
    address: b.address,
    category: b.category.name,
    location: b.address,
    rating: b.rating ?? 0.0,
    reviews: b.reviews ?? 0,
    growthScore: b.growthScore ?? 0,
    monthlyGrowth: b.monthlyGrowth ?? 0,
    verified: b.verified ?? false,
    followersCount: b._count?.followers ?? 0,
    productsCount: b._count?.products ?? 0,
    servicesCount: b._count?.services ?? 0,
    offersCount: b._count?.offers ?? 0,
    isSaved: currentUserId && Array.isArray(b.savedBy) ? b.savedBy.length > 0 : false,
    isFollowed: currentUserId && Array.isArray(b.followers) ? b.followers.length > 0 : false,
    products: b.products ?? [],
    services: b.services ?? [],
    offers: b.offers ?? [],
  };
}

export async function toggleSaveBusiness(userId: string, businessId: string) {
  const existing = await prisma.savedBusiness.findUnique({
    where: { userId_businessId: { userId, businessId } },
  });

  if (existing) {
    await prisma.savedBusiness.delete({ where: { id: existing.id } });
    return { isSaved: false };
  } else {
    await prisma.savedBusiness.create({ data: { userId, businessId } });
    return { isSaved: true };
  }
}

export async function toggleFollowBusiness(userId: string, businessId: string) {
  const existing = await prisma.businessFollow.findUnique({
    where: { userId_businessId: { userId, businessId } },
  });

  if (existing) {
    await prisma.businessFollow.delete({ where: { id: existing.id } });
    return { isFollowed: false };
  } else {
    await prisma.businessFollow.create({ data: { userId, businessId } });
    return { isFollowed: true };
  }
}

export async function getSavedBusinesses(userId: string) {
  const saved = await prisma.savedBusiness.findMany({
    where: { userId },
    include: {
      business: {
        include: {
          category: true,
          _count: { select: { followers: true } },
          followers: { where: { userId } },
        },
      },
    },
    orderBy: { savedAt: "desc" },
  });

  return saved.map((s: any) => ({
    id: s.business.id,
    name: s.business.name,
    slug: s.business.slug,
    description: s.business.description,
    logo: s.business.logo,
    cover: s.business.cover,
    category: s.business.category.name,
    location: s.business.address,
    rating: s.business.rating ?? 0.0,
    reviews: s.business.reviews ?? 0,
    growthScore: s.business.growthScore ?? 0,
    monthlyGrowth: s.business.monthlyGrowth ?? 0,
    verified: s.business.verified ?? false,
    followersCount: s.business._count?.followers ?? 0,
    isSaved: true,
    isFollowed: Array.isArray(s.business.followers) ? s.business.followers.length > 0 : false,
  }));
}

export async function getSearchSuggestions(query: string) {
  if (!query || query.trim() === "") {
    return { businesses: [], categories: [], products: [], services: [] };
  }

  const q = query.trim();

  const [businesses, categories, products, services] = await Promise.all([
    prisma.business.findMany({
      where: {
        OR: [
          { name: { contains: q, mode: "insensitive" } },
          { description: { contains: q, mode: "insensitive" } },
        ],
      },
      take: 5,
      include: { category: true },
    }),
    prisma.category.findMany({
      where: { name: { contains: q, mode: "insensitive" } },
      take: 5,
    }),
    prisma.product.findMany({
      where: { name: { contains: q, mode: "insensitive" } },
      take: 5,
      include: { business: { select: { id: true, name: true } } },
    }),
    prisma.service.findMany({
      where: { name: { contains: q, mode: "insensitive" } },
      take: 5,
      include: { business: { select: { id: true, name: true } } },
    }),
  ]);

  return {
    businesses: businesses.map((b) => ({
      id: b.id,
      name: b.name,
      category: b.category.name,
      logo: b.logo,
      rating: b.rating ?? 0.0,
    })),
    categories: categories.map((c) => ({
      id: c.id,
      name: c.name,
      icon: c.icon,
    })),
    products: products.map((p) => ({
      id: p.id,
      title: p.name,
      price: p.price,
      businessId: p.businessId,
      businessName: p.business.name,
    })),
    services: services.map((s) => ({
      id: s.id,
      title: s.name,
      price: s.price,
      businessId: s.businessId,
      businessName: s.business.name,
    })),
  };
}
