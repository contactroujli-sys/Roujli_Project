export interface UserProfile {
    id: string;
    email: string;
    role: string;
    isVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
    profile: {
        firstName: string;
        lastName: string;
        phone: string | null;
        avatar: string | null;
        bio: string | null;
        country: string | null;
        city: string | null;
    };
    business: {
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
    } | null;
}
export interface BusinessCount {
    type: string;
    count: number;
}
export interface Membership {
    type: string;
    status: string;
    expiresAt: Date | null;
}
export interface ProfileData {
    user: UserProfile;
    businessCounts: BusinessCount[];
    membership: Membership;
}
export interface UpdateProfileData {
    firstName?: string;
    lastName?: string;
    phone?: string;
    avatar?: string;
    bio?: string;
    country?: string;
    city?: string;
}
export interface UpdateBusinessData {
    name?: string;
    description?: string;
    logo?: string;
    cover?: string;
    phone?: string;
    email?: string;
    website?: string;
    whatsapp?: string;
    address?: string;
    categoryId?: string;
    categoryName?: string;
}
//# sourceMappingURL=profiles.types.d.ts.map