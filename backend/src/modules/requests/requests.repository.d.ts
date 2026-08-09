import { RequestType, RequestStatus } from "@prisma/client";
export declare function createRequest(userId: string, data: {
    businessId: string;
    type: RequestType;
    productId?: string;
    serviceId?: string;
    offerId?: string;
    name: string;
    phone?: string;
    email?: string;
    note?: string;
    quantity?: number;
    preferredDate?: Date;
}): Promise<{
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
        rating: number;
        reviews: number;
        ownerId: string;
        categoryId: string;
        createdAt: Date;
        updatedAt: Date;
    };
    offer: {
        id: string;
        title: string;
        description: string | null;
        discount: number | null;
        image: string | null;
        expiresAt: Date | null;
        businessId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
    product: {
        id: string;
        name: string;
        description: string | null;
        price: number;
        image: string | null;
        businessId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
    service: {
        id: string;
        name: string;
        description: string | null;
        price: number;
        duration: number | null;
        image: string | null;
        businessId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
} & {
    id: string;
    type: import("@prisma/client").$Enums.RequestType;
    status: import("@prisma/client").$Enums.RequestStatus;
    userId: string;
    businessId: string;
    productId: string | null;
    serviceId: string | null;
    offerId: string | null;
    name: string;
    phone: string | null;
    email: string | null;
    note: string | null;
    quantity: number;
    preferredDate: Date | null;
    ownerNote: string | null;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function getMyRequests(userId: string): Promise<({
    business: {
        id: string;
        logo: string | null;
        name: string;
    };
    offer: {
        discount: number | null;
        id: string;
        title: string;
    } | null;
    product: {
        id: string;
        name: string;
        price: number;
    } | null;
    service: {
        id: string;
        name: string;
        price: number;
    } | null;
} & {
    id: string;
    type: import("@prisma/client").$Enums.RequestType;
    status: import("@prisma/client").$Enums.RequestStatus;
    userId: string;
    businessId: string;
    productId: string | null;
    serviceId: string | null;
    offerId: string | null;
    name: string;
    phone: string | null;
    email: string | null;
    note: string | null;
    quantity: number;
    preferredDate: Date | null;
    ownerNote: string | null;
    createdAt: Date;
    updatedAt: Date;
})[]>;
export declare function getIncomingRequests(userId: string): Promise<({
    offer: {
        discount: number | null;
        id: string;
        title: string;
    } | null;
    product: {
        id: string;
        name: string;
        price: number;
    } | null;
    service: {
        id: string;
        name: string;
        price: number;
    } | null;
    user: {
        email: string;
        id: string;
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
    };
} & {
    id: string;
    type: import("@prisma/client").$Enums.RequestType;
    status: import("@prisma/client").$Enums.RequestStatus;
    userId: string;
    businessId: string;
    productId: string | null;
    serviceId: string | null;
    offerId: string | null;
    name: string;
    phone: string | null;
    email: string | null;
    note: string | null;
    quantity: number;
    preferredDate: Date | null;
    ownerNote: string | null;
    createdAt: Date;
    updatedAt: Date;
})[]>;
export declare function getRequestById(id: string, userId: string): Promise<({
    business: {
        id: string;
        logo: string | null;
        name: string;
        ownerId: string;
    };
    offer: {
        id: string;
        title: string;
        description: string | null;
        discount: number | null;
        image: string | null;
        expiresAt: Date | null;
        businessId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
    product: {
        id: string;
        name: string;
        description: string | null;
        price: number;
        image: string | null;
        businessId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
    service: {
        id: string;
        name: string;
        description: string | null;
        price: number;
        duration: number | null;
        image: string | null;
        businessId: string;
        createdAt: Date;
        updatedAt: Date;
    } | null;
    user: {
        email: string;
        id: string;
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
    };
} & {
    id: string;
    type: import("@prisma/client").$Enums.RequestType;
    status: import("@prisma/client").$Enums.RequestStatus;
    userId: string;
    businessId: string;
    productId: string | null;
    serviceId: string | null;
    offerId: string | null;
    name: string;
    phone: string | null;
    email: string | null;
    note: string | null;
    quantity: number;
    preferredDate: Date | null;
    ownerNote: string | null;
    createdAt: Date;
    updatedAt: Date;
}) | null>;
export declare function updateRequestStatus(id: string, ownerUserId: string, status: RequestStatus, ownerNote?: string): Promise<{
    id: string;
    type: import("@prisma/client").$Enums.RequestType;
    status: import("@prisma/client").$Enums.RequestStatus;
    userId: string;
    businessId: string;
    productId: string | null;
    serviceId: string | null;
    offerId: string | null;
    name: string;
    phone: string | null;
    email: string | null;
    note: string | null;
    quantity: number;
    preferredDate: Date | null;
    ownerNote: string | null;
    createdAt: Date;
    updatedAt: Date;
}>;
//# sourceMappingURL=requests.repository.d.ts.map