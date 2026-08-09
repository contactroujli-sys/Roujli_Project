import { PrismaClient, Role, SubscriptionType } from '@prisma/client';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

import { hashPassword } from '../src/utils/password.js';

const prisma = new PrismaClient();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  console.log('Starting seed process...');
  const hashedPassword = await hashPassword('Password123!');
  const adminPassword = await hashPassword('admin');

  console.log('Ensuring admin user exists...');
  await prisma.user.upsert({
    where: { email: 'admin@roujli.com' },
    update: {
      role: 'ADMIN',
      isVerified: true,
      password: adminPassword,
    },
    create: {
      id: 'admin-1',
      email: 'admin@roujli.com',
      password: adminPassword,
      role: 'ADMIN',
      isVerified: true,
      profile: {
        create: {
          firstName: 'Super',
          lastName: 'Admin',
        }
      }
    }
  });

  const dataPath = path.resolve(__dirname, '../../mock_data.json');
  const mockDataStr = await fs.readFile(dataPath, 'utf-8');
  const mockData = JSON.parse(mockDataStr);

  // 1. Create categories (from businesses)
  const categoryNames = [...new Set(mockData.businesses.map((b: any) => b.category))];
  for (const catName of categoryNames) {
    await prisma.category.upsert({
      where: { name: catName as string },
      update: {},
      create: { name: catName as string },
    });
  }
  console.log(`Ensured ${categoryNames.length} categories.`);

  // 2. Create users and profiles
  for (const user of mockData.users) {
    const roleMapping: Record<string, Role> = {
      'customer': 'CUSTOMER',
      'business_owner': 'BUSINESS',
      'admin': 'ADMIN'
    };
    const role = roleMapping[user.role] || 'CUSTOMER';
    
    const createdUser = await prisma.user.upsert({
      where: { email: user.email },
      update: {
        role,
        isVerified: true
      },
      create: {
        id: user.id,
        email: user.email,
        password: hashedPassword,
        role,
        isVerified: true,
        createdAt: new Date(user.joinedAt),
      }
    });

    // Profile
    await prisma.profile.upsert({
      where: { userId: createdUser.id },
      update: {
        firstName: user.firstName,
        lastName: user.lastName,
        avatar: user.avatar,
      },
      create: {
        userId: createdUser.id,
        firstName: user.firstName,
        lastName: user.lastName,
        avatar: user.avatar,
      }
    });
  }
  console.log(`Seeded ${mockData.users.length} users.`);

  // 3. Subscription Plans (just in case they are missing, for the demo)
  const plans = [
    { type: SubscriptionType.FREE, price: 0, maxProducts: 10, maxServices: 5, priority: 0 },
    { type: SubscriptionType.PLUS, price: 19.99, maxProducts: 50, maxServices: 20, priority: 1, verifiedBadge: true },
    { type: SubscriptionType.PREMIUM, price: 49.99, maxProducts: 9999, maxServices: 9999, priority: 2, verifiedBadge: true }
  ];
  for (const plan of plans) {
    await prisma.subscriptionPlan.upsert({
      where: { type: plan.type },
      update: {},
      create: plan,
    });
  }
  
  const freePlan = await prisma.subscriptionPlan.findUnique({ where: { type: SubscriptionType.FREE } });

  // 4. Create businesses
  for (const business of mockData.businesses) {
    const category = await prisma.category.findUnique({ where: { name: business.category } });
    if (!category) continue;

    let ownerId = `owner-${business.id}`;
    
    // Ensure this mock owner exists
    await prisma.user.upsert({
      where: { email: `${ownerId}@example.com` },
      update: {},
      create: {
        id: ownerId,
        email: `${ownerId}@example.com`,
        password: hashedPassword,
        role: 'BUSINESS',
        isVerified: true,
      }
    });

    // Generate slug from name
    const slug = business.name.toLowerCase().replace(/[^a-z0-9]+/g, '-');

    const createdBusiness = await prisma.business.upsert({
      where: { id: business.id },
      update: {
        name: business.name,
        slug,
        description: business.description,
        logo: business.logo,
        cover: business.coverImage,
        address: business.address,
        rating: business.rating,
        verified: business.verified,
        growthScore: business.growthScore,
        categoryId: category.id,
        ownerId: ownerId,
      },
      create: {
        id: business.id,
        name: business.name,
        slug,
        description: business.description,
        logo: business.logo,
        cover: business.coverImage,
        address: business.address,
        rating: business.rating,
        verified: business.verified,
        growthScore: business.growthScore,
        categoryId: category.id,
        ownerId: ownerId,
        createdAt: new Date(business.createdAt),
      }
    });

    // Subscriptions demo data
    if (freePlan) {
      const existingSub = await prisma.userSubscription.findFirst({ where: { userId: ownerId } });
      if (!existingSub) {
        await prisma.userSubscription.create({
          data: {
            userId: ownerId,
            planId: freePlan.id,
            status: 'ACTIVE'
          }
        });
      }
    }
  }
  console.log(`Seeded ${mockData.businesses.length} businesses.`);

  // 5. Products
  for (const product of mockData.products) {
    await prisma.product.upsert({
      where: { id: product.id },
      update: {
        name: product.name,
        description: product.description,
        price: product.price,
        currency: product.currency,
        stock: product.stock,
        rating: product.rating,
        image: product.image,
      },
      create: {
        id: product.id,
        businessId: product.businessId,
        name: product.name,
        description: product.description,
        price: product.price,
        currency: product.currency,
        stock: product.stock,
        rating: product.rating,
        image: product.image,
      }
    });
  }
  console.log(`Seeded ${mockData.products.length} products.`);

  // 6. Services
  for (const service of mockData.services) {
    let durationMins = 0;
    if (typeof service.duration === 'string') {
      const match = service.duration.match(/(\d+)\s*(hour|day|min)/i);
      if (match) {
        const val = parseInt(match[1]);
        const unit = match[2].toLowerCase();
        if (unit.startsWith('hour')) durationMins = val * 60;
        else if (unit.startsWith('day')) durationMins = val * 60 * 24;
        else if (unit.startsWith('min')) durationMins = val;
      }
    }

    await prisma.service.upsert({
      where: { id: service.id },
      update: {
        name: service.name,
        description: service.description,
        price: service.price,
        currency: service.currency,
        duration: durationMins || null,
        image: service.image,
      },
      create: {
        id: service.id,
        businessId: service.businessId,
        name: service.name,
        description: service.description,
        price: service.price,
        currency: service.currency,
        duration: durationMins || null,
        image: service.image,
      }
    });
  }
  console.log(`Seeded ${mockData.services.length} services.`);

  // 7. Offers
  for (const offer of mockData.offers) {
    const discount = offer.discountPercentage || offer.discountPrice;
    const discountType = offer.discountPercentage ? 'PERCENTAGE' : 'FIXED';

    await prisma.offer.upsert({
      where: { id: offer.id },
      update: {
        title: offer.title,
        description: offer.description,
        code: offer.code,
        discount,
        discountType,
        currency: offer.currency || 'USD',
        expiresAt: offer.validUntil ? new Date(offer.validUntil) : null,
        image: offer.image,
      },
      create: {
        id: offer.id,
        businessId: offer.businessId,
        title: offer.title,
        description: offer.description,
        code: offer.code,
        discount,
        discountType,
        currency: offer.currency || 'USD',
        expiresAt: offer.validUntil ? new Date(offer.validUntil) : null,
        image: offer.image,
      }
    });
  }
  console.log(`Seeded ${mockData.offers.length} offers.`);

  // 8. PlatformMetrics
  if (mockData.growth?.monthlySeries) {
    for (const item of mockData.growth.monthlySeries) {
      await prisma.platformMetric.upsert({
        where: { month: item.month },
        update: {
          revenue: item.revenue,
          users: item.users,
          activeBusinesses: item.activeBusinesses,
        },
        create: {
          month: item.month,
          revenue: item.revenue,
          users: item.users,
          activeBusinesses: item.activeBusinesses,
        }
      });
    }
  }

  // 9. AcquisitionChannels
  if (mockData.growth?.userAcquisitionByChannel) {
    for (const item of mockData.growth.userAcquisitionByChannel) {
      await prisma.acquisitionChannel.upsert({
        where: { channel: item.channel },
        update: {
          percentage: item.percentage
        },
        create: {
          channel: item.channel,
          percentage: item.percentage
        }
      });
    }
  }
  // 10. Configure specific test scenarios and seed metrics & history
  const { evaluateBusinessGrowth } = await import('../src/modules/businesses/growth.engine.js');

  // Business A (b-001): Lumina Coffee Roasters -> Strong profile, weak engagement
  await prisma.businessMetric.upsert({
    where: { businessId: "b-001" },
    update: { profileViews: 180, productViews: 40, serviceViews: 20, totalInteractions: 1, responseTimeMins: 20.0, responseRate: 98.0 },
    create: { businessId: "b-001", profileViews: 180, productViews: 40, serviceViews: 20, totalInteractions: 1, responseTimeMins: 20.0, responseRate: 98.0 }
  });

  // Business B (b-002): Zenith Fitness Studio -> High engagement
  await prisma.businessMetric.upsert({
    where: { businessId: "b-002" },
    update: { profileViews: 520, productViews: 310, serviceViews: 250, totalInteractions: 45, responseTimeMins: 15.0, responseRate: 95.0 },
    create: { businessId: "b-002", profileViews: 520, productViews: 310, serviceViews: 250, totalInteractions: 45, responseTimeMins: 15.0, responseRate: 95.0 }
  });

  // Business C (b-003): Nexus Tech Solutions -> Strong overall, poor response time (high response time, low response rate)
  await prisma.businessMetric.upsert({
    where: { businessId: "b-003" },
    update: { profileViews: 450, productViews: 120, serviceViews: 380, totalInteractions: 28, responseTimeMins: 240.0, responseRate: 45.0 },
    create: { businessId: "b-003", profileViews: 450, productViews: 120, serviceViews: 380, totalInteractions: 28, responseTimeMins: 240.0, responseRate: 45.0 }
  });

  // Evaluate growth score for all businesses & create historical snapshots
  const allBusinesses = await prisma.business.findMany();
  const pastDates = [
    new Date(Date.now() - 21 * 24 * 60 * 60 * 1000),
    new Date(Date.now() - 14 * 24 * 60 * 60 * 1000),
    new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
  ];

  for (const b of allBusinesses) {
    const evalRes = await evaluateBusinessGrowth(b.id);

    // Create history entries for trend testing
    for (let i = 0; i < pastDates.length; i++) {
      const historicalScore = Math.max(20, evalRes.scoreResult.growthScore - ((3 - i) * 4));
      const historyDate: Date = pastDates[i]!;
      const existing = await prisma.growthHistory.findFirst({
        where: { businessId: b.id, recordedAt: historyDate }
      });
      if (!existing) {
        await prisma.growthHistory.create({
          data: {
            businessId: b.id,
            score: historicalScore,
            breakdown: evalRes.scoreResult.breakdown,
            recordedAt: historyDate
          }
        });
      }
    }
  }

  console.log('Evaluated growth scores and generated growth history for test businesses.');
  console.log('Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
