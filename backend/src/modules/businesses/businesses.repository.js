import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
export async function listBusinesses(query, currentUserId) {
    const { search, categoryId, sort = "newest", page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;
    const where = {};
    if (search) {
        where.OR = [
            { name: { contains: search, mode: "insensitive" } },
            { description: { contains: search, mode: "insensitive" } },
            { category: { name: { contains: search, mode: "insensitive" } } },
        ];
    }
    if (categoryId && categoryId !== "0" && categoryId !== "All") {
        where.categoryId = categoryId;
    }
    let orderBy = { createdAt: "desc" };
    if (sort === "rating")
        orderBy = { rating: "desc" };
    if (sort === "growth")
        orderBy = { growthScore: "desc" };
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
    const items = businesses.map((b) => ({
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
export async function getBusinessById(id, currentUserId) {
    const b = await prisma.business.findUnique({
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
    if (!b)
        return null;
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
export async function toggleSaveBusiness(userId, businessId) {
    const existing = await prisma.savedBusiness.findUnique({
        where: { userId_businessId: { userId, businessId } },
    });
    if (existing) {
        await prisma.savedBusiness.delete({ where: { id: existing.id } });
        return { isSaved: false };
    }
    else {
        await prisma.savedBusiness.create({ data: { userId, businessId } });
        return { isSaved: true };
    }
}
export async function toggleFollowBusiness(userId, businessId) {
    const existing = await prisma.businessFollow.findUnique({
        where: { userId_businessId: { userId, businessId } },
    });
    if (existing) {
        await prisma.businessFollow.delete({ where: { id: existing.id } });
        return { isFollowed: false };
    }
    else {
        await prisma.businessFollow.create({ data: { userId, businessId } });
        return { isFollowed: true };
    }
}
export async function getSavedBusinesses(userId) {
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
    return saved.map((s) => ({
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
//# sourceMappingURL=businesses.repository.js.map