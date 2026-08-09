export declare function createService(userId: string, data: {
    name: string;
    description?: string;
    price: number;
    duration?: number;
    image?: string;
}): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    duration: number | null;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function getServices(businessId: string): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    duration: number | null;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}[]>;
export declare function updateService(userId: string, id: string, data: {
    name?: string;
    description?: string;
    price?: number;
    duration?: number;
    image?: string;
}): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    duration: number | null;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function deleteService(userId: string, id: string): Promise<{
    id: string;
    name: string;
    description: string | null;
    price: number;
    duration: number | null;
    image: string | null;
    businessId: string;
    createdAt: Date;
    updatedAt: Date;
}>;
//# sourceMappingURL=services.services.d.ts.map