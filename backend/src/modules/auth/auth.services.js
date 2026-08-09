import { AppError } from "../../utils/AppError.js";
import { generateAccessToken, generateRefreshToken, verifyAccessToken, } from "../../utils/jwt.js";
import { hashPassword, comparePassword } from "../../utils/password.js";
import { sendVerificationEmail, sendPasswordResetEmail } from "../../utils/email.js";
import * as repo from "./auth.repository.js";
// ─── Helpers ──────────────────────────────────────────────────────────────────
function generateOtp() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}
function otpExpiresAt(minutes = 10) {
    return new Date(Date.now() + minutes * 60 * 1000);
}
function refreshTokenExpiresAt() {
    return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
}
function toAuthUser(user) {
    return {
        id: user.id,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified,
        profile: user.profile
            ? {
                firstName: user.profile.firstName,
                lastName: user.profile.lastName,
                avatar: user.profile.avatar,
            }
            : null,
    };
}
// ─── Register ─────────────────────────────────────────────────────────────────
export async function register(input) {
    const email = input.email.trim().toLowerCase();
    const existing = await repo.findUserByEmail(email);
    if (existing) {
        throw new AppError("An account with this email already exists.", 409);
    }
    const hashedPassword = await hashPassword(input.password);
    const user = await repo.createUser({
        email,
        password: hashedPassword,
        role: input.role,
        firstName: input.firstName,
        lastName: input.lastName,
    });
    const code = generateOtp();
    await repo.createVerificationCode(user.id, code, otpExpiresAt());
    await sendVerificationEmail(input.email, input.firstName, code);
}
// ─── Verify Email ─────────────────────────────────────────────────────────────
export async function verifyEmail(input) {
    const email = input.email.trim().toLowerCase();
    const user = await repo.findUserByEmail(email);
    if (!user) {
        throw new AppError("No account found with this email.", 404);
    }
    if (user.isVerified) {
        throw new AppError("This email is already verified.", 400);
    }
    const record = await repo.findVerificationCode(user.id, input.code);
    if (!record) {
        throw new AppError("Invalid or expired verification code.", 400);
    }
    await repo.deleteVerificationCode(record.id);
    await repo.markUserVerified(user.id);
    const tokens = await issueTokens(user.id, user);
    return { user: toAuthUser({ ...user, isVerified: true }), tokens };
}
// ─── Resend Code ──────────────────────────────────────────────────────────────
export async function resendCode(input) {
    const email = input.email.trim().toLowerCase();
    const user = await repo.findUserByEmail(email);
    if (!user) {
        // Return silently so we don't leak which emails exist
        return;
    }
    if (user.isVerified) {
        throw new AppError("This email is already verified.", 400);
    }
    const code = generateOtp();
    await repo.createVerificationCode(user.id, code, otpExpiresAt());
    await sendVerificationEmail(input.email, user.profile?.firstName ?? "User", code);
}
// ─── Login ────────────────────────────────────────────────────────────────────
export async function login(input) {
    const email = input.email.trim().toLowerCase();
    const user = await repo.findUserByEmail(email);
    if (!user) {
        throw new AppError("Invalid email or password.", 401);
    }
    const isMatch = await comparePassword(input.password, user.password);
    if (!isMatch) {
        throw new AppError("Invalid email or password.", 401);
    }
    if (!user.isVerified) {
        throw new AppError("Please verify your email before logging in. Check your inbox for a verification code.", 403);
    }
    const tokens = await issueTokens(user.id, user);
    return { user: toAuthUser(user), tokens };
}
// ─── Refresh Token ────────────────────────────────────────────────────────────
export async function refreshToken(input) {
    const record = await repo.findRefreshToken(input.refreshToken);
    if (!record || record.expiresAt < new Date()) {
        if (record)
            await repo.deleteRefreshToken(input.refreshToken);
        throw new AppError("Invalid or expired refresh token. Please log in again.", 401);
    }
    // Rotate refresh token (delete old, issue new)
    await repo.deleteRefreshToken(input.refreshToken);
    const newAccessToken = generateAccessToken({ userId: record.userId });
    const newRefreshToken = generateRefreshToken({ userId: record.userId });
    await repo.createRefreshToken(record.userId, newRefreshToken, refreshTokenExpiresAt());
    return { accessToken: newAccessToken, refreshToken: newRefreshToken };
}
// ─── Forgot Password ──────────────────────────────────────────────────────────
export async function forgotPassword(input) {
    const email = input.email.trim().toLowerCase();
    const user = await repo.findUserByEmail(email);
    // Always return silently to prevent email enumeration
    if (!user)
        return;
    const code = generateOtp();
    await repo.createPasswordResetToken(user.id, code, otpExpiresAt());
    await sendPasswordResetEmail(input.email, user.profile?.firstName ?? "User", code);
}
// ─── Reset Password ───────────────────────────────────────────────────────────
export async function resetPassword(input) {
    const email = input.email.trim().toLowerCase();
    const user = await repo.findUserByEmail(email);
    if (!user) {
        throw new AppError("Invalid or expired reset code.", 400);
    }
    const record = await repo.findPasswordResetToken(user.id, input.code);
    if (!record) {
        throw new AppError("Invalid or expired reset code.", 400);
    }
    const hashedPassword = await hashPassword(input.newPassword);
    await repo.deletePasswordResetToken(record.id);
    await repo.updateUserPassword(user.id, hashedPassword);
    // Invalidate all sessions after password reset
    await repo.deleteAllRefreshTokens(user.id);
}
// ─── Logout ───────────────────────────────────────────────────────────────────
export async function logout(refreshTokenStr) {
    await repo.deleteRefreshToken(refreshTokenStr);
}
// ─── Internal Helpers ─────────────────────────────────────────────────────────
async function issueTokens(userId, user) {
    const payload = { userId: user.id, email: user.email, role: user.role };
    const accessToken = generateAccessToken(payload);
    const refreshTokenStr = generateRefreshToken({ userId: user.id });
    await repo.createRefreshToken(userId, refreshTokenStr, refreshTokenExpiresAt());
    return { accessToken, refreshToken: refreshTokenStr };
}
//# sourceMappingURL=auth.services.js.map