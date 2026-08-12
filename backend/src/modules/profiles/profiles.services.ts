import type { ProfileData, UpdateProfileData, UpdateBusinessData } from "./profiles.types.js";
import * as repository from "./profiles.repository.js";
import prisma from "../../config/prisma.js";

// ─── Get Profile Data ─────────────────────────────────────────────────────

export async function getProfileData(userId: string): Promise<ProfileData> {
  const user = await repository.getUserProfile(userId);

  if (!user) {
    throw new Error("User not found");
  }

  const businessCounts = await repository.getBusinessCounts(userId);
  const membership = await repository.getMembership(userId);

  const profile = user.profile;
  const business = user.business;

  const followersCount = business ? await prisma.businessFollow.count({ where: { businessId: business.id } }) : 0;
  const followingCount = await prisma.businessFollow.count({ where: { userId: user.id } });

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
        followersCount,
        followingCount,
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

export async function updateProfileData(userId: string, updateData: UpdateProfileData) {
  await repository.updateUserProfile(userId, updateData);
  return getProfileData(userId);
}

// ─── Update Business Data ──────────────────────────────────────────────────

export async function updateBusinessData(userId: string, updateData: UpdateBusinessData) {
  const business = await repository.updateBusinessData(userId, updateData);
  return business;
}

export async function deleteBusiness(userId: string) {
  const result = await repository.deleteBusiness(userId);
  return result;
}

// ─── Update Privacy ────────────────────────────────────────────────────────

export async function updatePrivacy(userId: string, isPrivate: boolean) {
  return repository.updatePrivacy(userId, isPrivate);
}
