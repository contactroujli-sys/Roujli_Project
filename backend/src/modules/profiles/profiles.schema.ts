import { z } from "zod";

const optionalString = z.preprocess((val) => {
  if (val === null || val === undefined || (typeof val === "string" && val.trim() === "")) return undefined;
  return val;
}, z.string().trim().optional());

const optionalEmail = z.preprocess((val) => {
  if (val === null || val === undefined || (typeof val === "string" && val.trim() === "")) return undefined;
  return val;
}, z.string().trim().email().optional());

export const updateProfileSchema = z.object({
  firstName: optionalString,
  lastName: optionalString,
  phone: optionalString,
  avatar: optionalString,
  bio: optionalString,
  country: optionalString,
  city: optionalString,
});

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
