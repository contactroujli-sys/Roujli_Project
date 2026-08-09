export declare function getUserProfile(userId: string): Promise<({
    business: ({
        category: {
            id: string;
            name: string;
            icon: string | null;
            createdAt: Date;
        };
    } & {
        id: string;
        name: string;
        slug: string;
        description: string | null;
        logo: string | null;
        cover: string | null;
        phone: string | null;
        email: string | null;
        website: string | null;
        whatsapp: string | null;
        address: string | null;
        verified: boolean;
        growthScore: number;
        monthlyGrowth: number;
        rating: number;
        reviews: number;
        ownerId: string;
        categoryId: string;
        createdAt: Date;
        updatedAt: Date;
    }) | null;
    profile: {
        id: string;
        firstName: string;
        lastName: string;
        phone: string | null;
        avatar: string | null;
        bio: string | null;
        country: string | null;
        city: string | null;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
} & {
    id: string;
    email: string;
    password: string;
    role: import("@prisma/client").$Enums.Role;
    isVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
}) | null>;
export declare function updateUserProfile(userId: string, updateData: any): Promise<{
    business: ({
        category: {
            id: string;
            name: string;
            icon: string | null;
            createdAt: Date;
        };
    } & {
        id: string;
        name: string;
        slug: string;
        description: string | null;
        logo: string | null;
        cover: string | null;
        phone: string | null;
        email: string | null;
        website: string | null;
        whatsapp: string | null;
        address: string | null;
        verified: boolean;
        growthScore: number;
        monthlyGrowth: number;
        rating: number;
        reviews: number;
        ownerId: string;
        categoryId: string;
        createdAt: Date;
        updatedAt: Date;
    }) | null;
    profile: {
        id: string;
        firstName: string;
        lastName: string;
        phone: string | null;
        avatar: string | null;
        bio: string | null;
        country: string | null;
        city: string | null;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
} & {
    id: string;
    email: string;
    password: string;
    role: import("@prisma/client").$Enums.Role;
    isVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function updateBusinessData(userId: string, updateData: any): Promise<{
    category: {
        id: string;
        name: string;
        icon: string | null;
        createdAt: Date;
    };
} & {
    id: string;
    name: string;
    slug: string;
    description: string | null;
    logo: string | null;
    cover: string | null;
    phone: string | null;
    email: string | null;
    website: string | null;
    whatsapp: string | null;
    address: string | null;
    verified: boolean;
    growthScore: number;
    monthlyGrowth: number;
    rating: number;
    reviews: number;
    ownerId: string;
    categoryId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function deleteBusiness(userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
export declare function getBusinessCounts(userId: string): Promise<{
    businesses: number;
    products: number;
    services: number;
    offers: number;
    saved: number;
    requests: number;
}>;
export declare function getMembership(userId: string): Promise<{
    type: string;
    status: string;
    expiresAt: null;
} | {
    type: import("@prisma/client").$Enums.SubscriptionType;
    status: string;
    expiresAt: Date | null;
}>;
//# sourceMappingURL=profiles.repository.d.ts.map