import { AppError } from "../../utils/AppError.js";
import {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
} from "../../utils/jwt.js";
import { hashPassword, comparePassword } from "../../utils/password.js";
import { sendVerificationEmail, sendPasswordResetEmail, sendPasswordChangeNotificationEmail } from "../../utils/email.js";
import * as repo from "./auth.repository.js";
import prisma from "../../config/prisma.js";
import type {
  RegisterInput,
  LoginInput,
  VerifyEmailInput,
  ResendCodeInput,
  ForgotPasswordInput,
  ResetPasswordInput,
  RefreshTokenInput,
  AuthResponse,
  AuthTokens,
  AuthUser,
} from "./auth.types.js";

// ─── Helpers ──────────────────────────────────────────────────────────────────

function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function otpExpiresAt(minutes: number = 10): Date {
  return new Date(Date.now() + minutes * 60 * 1000);
}

function refreshTokenExpiresAt(): Date {
  return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
}

function toAuthUser(user: { id: string; email: string; role: any; isVerified: boolean; profile: { firstName: string; lastName: string; avatar: string | null } | null }): AuthUser {
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

export async function register(input: RegisterInput): Promise<void> {
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

export async function verifyEmail(input: VerifyEmailInput): Promise<AuthResponse> {
  const email = input.email.trim().toLowerCase();
  const user = await repo.findUserByEmail(email);
  if (!user) {
    throw new AppError("No account found with this email.", 404);
  }

  const record = await repo.findVerificationCode(user.id, input.code);
  if (!record) {
    throw new AppError("Invalid or expired verification code.", 400);
  }

  await repo.deleteVerificationCode(record.id);
  if (!user.isVerified) {
    await repo.markUserVerified(user.id);
  }

  const tokens = await issueTokens(user.id, user);
  return { user: toAuthUser({ ...user, isVerified: true }), tokens };
}

// ─── Resend Code ──────────────────────────────────────────────────────────────

export async function resendCode(input: ResendCodeInput): Promise<void> {
  const email = input.email.trim().toLowerCase();
  const user = await repo.findUserByEmail(email);
  if (!user) {
    // Return silently so we don't leak which emails exist
    return;
  }

  const code = generateOtp();
  await repo.createVerificationCode(user.id, code, otpExpiresAt());
  await sendVerificationEmail(
    input.email,
    user.profile?.firstName ?? "User",
    code
  );
}

// ─── Login ────────────────────────────────────────────────────────────────────

export async function login(input: LoginInput): Promise<AuthResponse> {
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
    const code = generateOtp();
    await repo.createVerificationCode(user.id, code, otpExpiresAt());
    await sendVerificationEmail(
      user.email,
      user.profile?.firstName ?? "User",
      code
    );
  }

  const tokens = await issueTokens(user.id, user);
  return { user: toAuthUser(user), tokens };
}

// ─── Refresh Token ────────────────────────────────────────────────────────────

export async function refreshToken(input: RefreshTokenInput): Promise<AuthTokens> {
  const record = await repo.findRefreshToken(input.refreshToken);

  if (!record || record.expiresAt < new Date()) {
    if (record) await repo.deleteRefreshToken(input.refreshToken);
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

export async function forgotPassword(input: ForgotPasswordInput): Promise<void> {
  const email = input.email.trim().toLowerCase();
  const user = await repo.findUserByEmail(email);

  // Always return silently to prevent email enumeration
  if (!user) return;

  const code = generateOtp();
  await repo.createPasswordResetToken(user.id, code, otpExpiresAt());
  await sendPasswordResetEmail(
    input.email,
    user.profile?.firstName ?? "User",
    code
  );
}

// ─── Reset Password ───────────────────────────────────────────────────────────

export async function resetPassword(input: ResetPasswordInput): Promise<void> {
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

export async function logout(refreshTokenStr: string): Promise<void> {
  await repo.deleteRefreshToken(refreshTokenStr);
}

// ─── Change Password ──────────────────────────────────────────────────────────

export async function changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void> {
  const user = await prisma.user.findUnique({ where: { id: userId }, include: { profile: true } });
  if (!user) throw new AppError("User not found.", 404);

  const isMatch = await comparePassword(currentPassword, user.password);
  if (!isMatch) throw new AppError("Current password is incorrect.", 400);

  const hashed = await hashPassword(newPassword);
  await repo.updateUserPassword(userId, hashed);
  // Invalidate all sessions after password change
  await repo.deleteAllRefreshTokens(userId);

  await sendPasswordChangeNotificationEmail(
    user.email,
    user.profile?.firstName ?? "User"
  );
}

// ─── Internal Helpers ─────────────────────────────────────────────────────────

async function issueTokens(
  userId: string,
  user: { id: string; email: string; role: any }
): Promise<AuthTokens> {
  const payload = { userId: user.id, email: user.email, role: user.role };
  const accessToken = generateAccessToken(payload);
  const refreshTokenStr = generateRefreshToken({ userId: user.id });

  await repo.createRefreshToken(userId, refreshTokenStr, refreshTokenExpiresAt());

  return { accessToken, refreshToken: refreshTokenStr };
}
