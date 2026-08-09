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

const optionalString = z.preprocess((val) => {
  if (val === null || val === undefined || (typeof val === "string" && val.trim() === "")) return undefined;
  return val;
}, z.string().trim().optional());

const optionalEmail = z.preprocess((val) => {
  if (val === null || val === undefined || (typeof val === "string" && val.trim() === "")) return undefined;
  return val;
}, z.string().trim().email().optional());

export const updateBusinessSchema = z.object({
  id: optionalString,
  name: z.string().trim().min(1, "Business name is required"),
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
