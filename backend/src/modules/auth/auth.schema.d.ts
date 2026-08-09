import { z } from "zod";
export declare const registerSchema: z.ZodObject<{
    firstName: z.ZodString;
    lastName: z.ZodString;
    email: z.ZodString;
    password: z.ZodString;
    role: z.ZodEnum<{
        CUSTOMER: 'CUSTOMER';
        BUSINESS: 'BUSINESS';
        SERVICE_PROVIDER: 'SERVICE_PROVIDER';
        CREATOR: 'CREATOR';
        ADMIN: 'ADMIN';
    }>;
}, z.core.$strip>;
export declare const loginSchema: z.ZodObject<{
    email: z.ZodString;
    password: z.ZodString;
}, z.core.$strip>;
export declare const verifyEmailSchema: z.ZodObject<{
    email: z.ZodString;
    code: z.ZodString;
}, z.core.$strip>;
export declare const resendCodeSchema: z.ZodObject<{
    email: z.ZodString;
}, z.core.$strip>;
export declare const forgotPasswordSchema: z.ZodObject<{
    email: z.ZodString;
}, z.core.$strip>;
export declare const resetPasswordSchema: z.ZodObject<{
    email: z.ZodString;
    code: z.ZodString;
    newPassword: z.ZodString;
}, z.core.$strip>;
export declare const refreshTokenSchema: z.ZodObject<{
    refreshToken: z.ZodString;
}, z.core.$strip>;
export declare const logoutSchema: z.ZodObject<{
    refreshToken: z.ZodString;
}, z.core.$strip>;
//# sourceMappingURL=auth.schema.d.ts.map