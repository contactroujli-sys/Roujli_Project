export declare function createService(businessId: string, data: {
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
export declare function getServicesByBusiness(businessId: string): Promise<{
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
export declare function updateService(id: string, businessId: string, data: {
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
export declare function deleteService(id: string, businessId: string): Promise<{
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
//# sourceMappingURL=services.repository.d.ts.map