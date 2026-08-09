import type { BusinessListQuery } from "./businesses.types.js";
export declare function listBusinesses(query: BusinessListQuery, currentUserId?: string): Promise<{
    items: {
        id: any;
        name: any;
        slug: any;
        description: any;
        logo: any;
        cover: any;
        category: any;
        location: any;
        rating: any;
        reviews: any;
        growthScore: any;
        monthlyGrowth: any;
        verified: any;
        followersCount: any;
        isSaved: boolean;
        isFollowed: boolean;
    }[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
}>;
export declare function getBusinessById(id: string, currentUserId?: string): Promise<{
    id: any;
    name: any;
    slug: any;
    description: any;
    logo: any;
    cover: any;
    phone: any;
    email: any;
    website: any;
    whatsapp: any;
    address: any;
    category: any;
    location: any;
    rating: any;
    reviews: any;
    growthScore: any;
    monthlyGrowth: any;
    verified: any;
    followersCount: any;
    productsCount: any;
    servicesCount: any;
    offersCount: any;
    isSaved: boolean;
    isFollowed: boolean;
    products: any;
    services: any;
    offers: any;
} | null>;
export declare function toggleSaveBusiness(userId: string, businessId: string): Promise<{
    isSaved: boolean;
}>;
export declare function toggleFollowBusiness(userId: string, businessId: string): Promise<{
    isFollowed: boolean;
}>;
export declare function getSavedBusinesses(userId: string): Promise<{
    id: any;
    name: any;
    slug: any;
    description: any;
    logo: any;
    cover: any;
    category: any;
    location: any;
    rating: any;
    reviews: any;
    growthScore: any;
    monthlyGrowth: any;
    verified: any;
    followersCount: any;
    isSaved: boolean;
    isFollowed: boolean;
}[]>;
//# sourceMappingURL=businesses.repository.d.ts.map