export declare function createProduct(userId: string, data: {
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
export declare function getProducts(businessId: string): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}[]>;
export declare function updateProduct(userId: string, id: string, data: {
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
export declare function deleteProduct(userId: string, id: string): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
//# sourceMappingURL=products.services.d.ts.map