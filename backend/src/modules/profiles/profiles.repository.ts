import prisma from "../../config/prisma.js";
import type { ProfileData } from "./profiles.types.js";

export async function getUserProfile(userId: string) {
  return prisma.user.findUnique({
    where: { id: userId },
    include: {
      profile: true,
      business: {
        include: {
          category: true,
        },
      },
    },
  });
}

export async function updateUserProfile(userId: string, updateData: any) {
  const { firstName, lastName, phone, avatar, bio, country, city } = updateData;

  return prisma.user.update({
    where: { id: userId },
    data: {
      profile: {
        upsert: {
          create: {
            firstName: firstName || "User",
            lastName: lastName || "",
            phone: phone || null,
            avatar: avatar || null,
            bio: bio || null,
            country: country || null,
            city: city || null,
          },
          update: {
            firstName: firstName || undefined,
            lastName: lastName || undefined,
            phone: phone || null,
            avatar: avatar || null,
            bio: bio || null,
            country: country || null,
            city: city || null,
          },
        },
      },
    },
    include: {
      profile: true,
      business: {
        include: {
          category: true,
        },
      },
    },
  });
}

export async function updateBusinessData(userId: string, updateData: any) {
  const {
    name,
    description,
    logo,
    cover,
    phone,
    email,
    website,
    whatsapp,
    address,
    categoryId,
  } = updateData;

  if (!name) {
    throw new Error("Business name is required");
  }

  const category =
    (categoryId && (await prisma.category.findUnique({ where: { id: categoryId } }))) ||
    (await getDefaultCategory());

  const slug = await generateUniqueSlug(name, userId);

  return prisma.business.upsert({
    where: { ownerId: userId },
    create: {
      name,
      slug,
      description: description || null,
      logo: logo || null,
      cover: cover || null,
      phone: phone || null,
      email: email || null,
      website: website || null,
      whatsapp: whatsapp || null,
      address: address || null,
      ownerId: userId,
      categoryId: category.id,
    },
    update: {
      name,
      slug,
      description: description ?? null,
      logo: logo ?? null,
      cover: cover ?? null,
      phone: phone ?? null,
      email: email ?? null,
      website: website ?? null,
      whatsapp: whatsapp ?? null,
      address: address ?? null,
      categoryId: category.id,
    },
    include: {
      category: true,
    },
  });
}

async function generateUniqueSlug(name: string, userId: string) {
  const baseSlug = name
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  let slug = baseSlug || "business";
  let count = 1;

  while (true) {
    const existing = await prisma.business.findUnique({ where: { slug } });
    if (!existing || existing.ownerId === userId) {
      return slug;
    }
    slug = `${baseSlug}-${count++}`;
  }
}

async function getDefaultCategory() {
  let category = await prisma.category.findFirst();
  if (!category) {
    category = await prisma.category.create({
      data: {
        name: "General",
        icon: "general",
      },
    });
  }
  return category;
}

export async function deleteBusiness(userId: string) {
  const business = await prisma.business.findUnique({ where: { ownerId: userId } });
  if (!business) {
    return { count: 0 };
  }

  await prisma.product.deleteMany({ where: { businessId: business.id } });
  await prisma.service.deleteMany({ where: { businessId: business.id } });

  return prisma.business.deleteMany({ where: { ownerId: userId } });
}

export async function getBusinessCounts(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      business: {
        include: {
          products: true,
          services: true,
        },
      },
    },
  });

  if (!user) {
    return {
      businesses: 0,
      products: 0,
      services: 0,
      offers: 0,
      saved: 0,
      requests: 0,
    };
  }

  const business = user.business;
  const products = business?.products || [];
  const services = business?.services || [];

  return {
    businesses: business ? 1 : 0,
    products: products.length || 0,
    services: services.length || 0,
    offers: 0, // No offers table in schema yet
    saved: 0, // No saved items table in schema yet
    requests: 0, // No requests table in schema yet
  };
}

export async function getMembership(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      subscriptions: {
        include: {
          plan: true,
        },
        orderBy: {
          startDate: 'desc',
        },
        take: 1,
      },
    },
  });

  if (!user || user.subscriptions.length === 0) {
    return {
      type: "FREE",
      status: "active",
      expiresAt: null,
    };
  }

  const subscription = user.subscriptions[0];
  if (!subscription) {
    return {
      type: "FREE",
      status: "active",
      expiresAt: null,
    };
  }

  return {
    type: subscription.plan.type,
    status: subscription.status.toLowerCase(),
    expiresAt: subscription.endDate,
  };
}

export async function updatePrivacy(userId: string, isPrivate: boolean) {
  return prisma.user.update({
    where: { id: userId },
    data: { isPrivate },
    select: { id: true, isPrivate: true },
  });
}
