export declare function createProduct(businessId: string, data: {
    name: string;
    description?: string;
    price: number;
    image?: string;
}): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function getProductsByBusiness(businessId: string): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}[]>;
export declare function updateProduct(id: string, businessId: string, data: {
    name?: string;
    description?: string;
    price?: number;
    image?: string;
}): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function deleteProduct(id: string, businessId: string): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
//# sourceMappingURL=products.repository.d.ts.map