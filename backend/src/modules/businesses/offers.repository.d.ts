export declare function createOffer(businessId: string, data: {
    title: string;
    description?: string;
    discount?: number;
    image?: string;
    expiresAt?: Date;
}): Promise<{
    id: string;
    title: string;
    description: string | null;
    discount: number | null;
    image: string | null;
    expiresAt: Date | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function getOffersByBusiness(businessId: string): Promise<{
    id: string;
    title: string;
    description: string | null;
    discount: number | null;
    image: string | null;
    expiresAt: Date | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}[]>;
export declare function updateOffer(id: string, businessId: string, data: {
    title?: string;
    description?: string;
    discount?: number;
    image?: string;
    expiresAt?: Date;
}): Promise<{
    id: string;
    title: string;
    description: string | null;
    discount: number | null;
    image: string | null;
    expiresAt: Date | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function deleteOffer(id: string, businessId: string): Promise<{
    id: string;
    title: string;
    description: string | null;
    discount: number | null;
    image: string | null;
    expiresAt: Date | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
//# sourceMappingURL=offers.repository.d.ts.map