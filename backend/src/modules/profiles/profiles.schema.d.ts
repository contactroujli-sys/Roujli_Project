import { z } from "zod";
export declare const updateProfileSchema: z.ZodObject<{
    firstName: z.ZodOptional<z.ZodString>;
    lastName: z.ZodOptional<z.ZodString>;
    phone: z.ZodOptional<z.ZodString>;
    avatar: z.ZodOptional<z.ZodString>;
    bio: z.ZodOptional<z.ZodString>;
    country: z.ZodOptional<z.ZodString>;
    city: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
export declare const updateBusinessSchema: z.ZodObject<{
    name: z.ZodString;
    description: z.ZodOptional<z.ZodString>;
    logo: z.ZodOptional<z.ZodString>;
    cover: z.ZodOptional<z.ZodString>;
    phone: z.ZodOptional<z.ZodString>;
    email: z.ZodPreprocess<z.ZodOptional<z.ZodString>>;
    website: z.ZodOptional<z.ZodString>;
    whatsapp: z.ZodOptional<z.ZodString>;
    address: z.ZodOptional<z.ZodString>;
    categoryId: z.ZodOptional<z.ZodString>;
    categoryName: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
//# sourceMappingURL=profiles.schema.d.ts.map