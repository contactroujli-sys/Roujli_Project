import { z } from "zod";
export const updateProfileSchema = z.object({
    firstName: z.string().trim().min(1).optional(),
    lastName: z.string().trim().min(1).optional(),
    phone: z.string().trim().optional(),
    avatar: z.string().trim().optional(),
    bio: z.string().trim().optional(),
    country: z.string().trim().optional(),
    city: z.string().trim().optional(),
});
const optionalString = z.string().trim().optional();
const optionalEmail = z.preprocess((value) => {
    if (typeof value === "string" && value.trim() === "")
        return undefined;
    return value;
}, z.string().trim().email().optional());
const optionalUrl = z.preprocess((value) => {
    if (typeof value === "string" && value.trim() === "")
        return undefined;
    return value;
}, z.string().trim().url().optional());
export const updateBusinessSchema = z.object({
    name: z.string().trim().min(1),
    description: optionalString,
    logo: optionalString,
    cover: optionalString,
    phone: optionalString,
    email: optionalEmail,
    website: optionalString,
    whatsapp: optionalString,
    address: optionalString,
    categoryId: optionalString,
    categoryName: optionalString,
});
//# sourceMappingURL=profiles.schema.js.map