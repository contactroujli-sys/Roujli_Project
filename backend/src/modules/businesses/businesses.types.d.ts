export interface BusinessListItem {
    id: string;
    name: string;
    slug: string;
    description: string | null;
    logo: string | null;
    cover: string | null;
    category: string;
    location: string | null;
    rating: number;
    reviews: number;
    growthScore: number;
    monthlyGrowth: number;
    verified: boolean;
    followersCount: number;
    isSaved: boolean;
    isFollowed: boolean;
}
export interface ProductItem {
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
}
export interface ServiceItem {
    id: string;
    name: string;
    description: string | null;
    price: number;
    duration: number | null;
    image: string | null;
}
export interface OfferItem {
    id: string;
    title: string;
    description: string | null;
    discount: number | null;
    image: string | null;
    expiresAt: Date | null;
}
export interface BusinessDetail extends BusinessListItem {
    phone: string | null;
    email: string | null;
    website: string | null;
    whatsapp: string | null;
    address: string | null;
    productsCount: number;
    servicesCount: number;
    offersCount: number;
    products: ProductItem[];
    services: ServiceItem[];
    offers: OfferItem[];
}
export interface BusinessListQuery {
    search?: string;
    categoryId?: string;
    sort?: "rating" | "growth" | "newest";
    page?: number;
    limit?: number;
}
//# sourceMappingURL=businesses.types.d.ts.map