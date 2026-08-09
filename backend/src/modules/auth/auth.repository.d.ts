import type { Role } from "@prisma/client";
export declare function findUserByEmail(email: string): Promise<({
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
export declare function createUser(data: {
    email: string;
    password: string;
    role: Role;
    firstName: string;
    lastName: string;
}): Promise<{
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
export declare function markUserVerified(userId: string): Promise<{
    id: string;
    email: string;
    password: string;
    role: import("@prisma/client").$Enums.Role;
    isVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function updateUserPassword(userId: string, hashedPassword: string): Promise<{
    id: string;
    email: string;
    password: string;
    role: import("@prisma/client").$Enums.Role;
    isVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
}>;
export declare function createVerificationCode(userId: string, code: string, expiresAt: Date): Promise<{
    id: string;
    code: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
}>;
export declare function findVerificationCode(userId: string, code: string): Promise<{
    id: string;
    code: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
} | null>;
export declare function deleteVerificationCode(id: string): Promise<{
    id: string;
    code: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
}>;
export declare function deleteAllVerificationCodes(userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
export declare function createRefreshToken(userId: string, token: string, expiresAt: Date): Promise<{
    id: string;
    token: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
}>;
export declare function findRefreshToken(token: string): Promise<({
    user: {
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
    };
} & {
    id: string;
    token: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
}) | null>;
export declare function deleteRefreshToken(token: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
export declare function deleteAllRefreshTokens(userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
export declare function createPasswordResetToken(userId: string, code: string, expiresAt: Date): Promise<{
    id: string;
    code: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
}>;
export declare function findPasswordResetToken(userId: string, code: string): Promise<{
    id: string;
    code: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
} | null>;
export declare function deletePasswordResetToken(id: string): Promise<{
    id: string;
    code: string;
    expiresAt: Date;
    userId: string;
    createdAt: Date;
}>;
export declare function deleteAllPasswordResetTokens(userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
//# sourceMappingURL=auth.repository.d.ts.map