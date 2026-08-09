import { z } from "zod";
import { Role } from "@prisma/client";
export const registerSchema = z.object({
    firstName: z.string().min(2, "First name must be at least 2 characters"),
    lastName: z.string().min(2, "Last name must be at least 2 characters"),
    email: z.string().email("Invalid email address"),
    password: z.string().min(8, "Password must be at least 8 characters"),
    role: z.nativeEnum(Role, { error: "Invalid role" }),
});
export const loginSchema = z.object({
    email: z.string().email("Invalid email address"),
    password: z.string().min(1, "Password is required"),
});
export const verifyEmailSchema = z.object({
    email: z.string().email("Invalid email address"),
    code: z.string().length(6, "Code must be exactly 6 digits"),
});
export const resendCodeSchema = z.object({
    email: z.string().email("Invalid email address"),
});
export const forgotPasswordSchema = z.object({
    email: z.string().email("Invalid email address"),
});
export const resetPasswordSchema = z.object({
    email: z.string().email("Invalid email address"),
    code: z.string().length(6, "Code must be exactly 6 digits"),
    newPassword: z.string().min(8, "Password must be at least 8 characters"),
});
export const refreshTokenSchema = z.object({
    refreshToken: z.string().min(1, "Refresh token is required"),
});
export const logoutSchema = z.object({
    refreshToken: z.string().min(1, "Refresh token is required"),
});
//# sourceMappingURL=auth.schema.js.map