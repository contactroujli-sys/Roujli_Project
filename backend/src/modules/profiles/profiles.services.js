import * as repository from "./profiles.repository.js";
// ─── Get Profile Data ─────────────────────────────────────────────────────
export async function getProfileData(userId) {
    const user = await repository.getUserProfile(userId);
    if (!user) {
        throw new Error("User not found");
    }
    const businessCounts = await repository.getBusinessCounts(userId);
    const membership = await repository.getMembership(userId);
    // Handle null values - 0 for numbers, empty string/hints for text
    const profile = user.profile;
    const business = user.business;
    return {
        user: {
            id: user.id,
            email: user.email,
            role: user.role,
            isVerified: user.isVerified,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
            profile: {
                firstName: profile?.firstName || "User",
                lastName: profile?.lastName || "",
                phone: profile?.phone || null,
                avatar: profile?.avatar || null,
                bio: profile?.bio || null,
                country: profile?.country || null,
                city: profile?.city || null,
            },
            business: business ? {
                id: business.id,
                name: business.name,
                slug: business.slug,
                description: business.description || null,
                logo: business.logo || null,
                cover: business.cover || null,
                phone: business.phone || null,
                email: business.email || null,
                website: business.website || null,
                whatsapp: business.whatsapp || null,
                address: business.address || null,
                verified: business.verified,
                growthScore: business.growthScore ?? 0,
                monthlyGrowth: business.monthlyGrowth ?? 0,
            } : null,
        },
        businessCounts: [
            {
                type: "My Businesses",
                count: businessCounts.businesses ?? 0,
            },
            {
                type: "My Products",
                count: businessCounts.products ?? 0,
            },
            {
                type: "My Services",
                count: businessCounts.services ?? 0,
            },
            {
                type: "My Offers",
                count: businessCounts.offers ?? 0,
            },
            {
                type: "Saved",
                count: businessCounts.saved ?? 0,
            },
            {
                type: "My Requests",
                count: businessCounts.requests ?? 0,
            },
        ],
        membership: {
            type: membership.type || "FREE",
            status: membership.status || "active",
            expiresAt: membership.expiresAt || null,
        },
    };
}
// ─── Update Profile Data ───────────────────────────────────────────────────
export async function updateProfileData(userId, updateData) {
    const user = await repository.updateUserProfile(userId, updateData);
    return user;
}
// ─── Update Business Data ──────────────────────────────────────────────────
export async function updateBusinessData(userId, updateData) {
    const business = await repository.updateBusinessData(userId, updateData);
    return business;
}
export async function deleteBusiness(userId) {
    const result = await repository.deleteBusiness(userId);
    return result;
}
//# sourceMappingURL=profiles.services.js.map