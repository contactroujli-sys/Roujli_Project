import prisma from "../../config/prisma.js";
import type { Role } from "@prisma/client";

// ─── User ─────────────────────────────────────────────────────────────────────

export async function findUserByEmail(email: string) {
  return prisma.user.findFirst({
    where: {
      email: {
        equals: email.trim().toLowerCase(),
        mode: "insensitive",
      },
    },
    include: {
      profile: true,
    },
  });
}

export async function createUser(data: {
  email: string;
  password: string;
  role: Role;
  firstName: string;
  lastName: string;
}) {
  return prisma.user.create({
    data: {
      email: data.email.trim().toLowerCase(),
      password: data.password,
      role: data.role,
      profile: {
        create: {
          firstName: data.firstName,
          lastName: data.lastName,
        },
      },
    },
    include: {
      profile: true,
    },
  });
}

export async function markUserVerified(userId: string) {
  return prisma.user.update({
    where: { id: userId },
    data: { isVerified: true },
  });
}

export async function updateUserPassword(userId: string, hashedPassword: string) {
  return prisma.user.update({
    where: { id: userId },
    data: { password: hashedPassword },
  });
}

// ─── Verification Codes ───────────────────────────────────────────────────────

export async function createVerificationCode(userId: string, code: string, expiresAt: Date) {
  // Delete any existing codes for this user first
  await prisma.verificationCode.deleteMany({ where: { userId } });

  return prisma.verificationCode.create({
    data: { userId, code, expiresAt },
  });
}

export async function findVerificationCode(userId: string, code: string) {
  return prisma.verificationCode.findFirst({
    where: {
      userId,
      code,
      expiresAt: { gt: new Date() },
    },
  });
}

export async function deleteVerificationCode(id: string) {
  return prisma.verificationCode.delete({ where: { id } });
}

export async function deleteAllVerificationCodes(userId: string) {
  return prisma.verificationCode.deleteMany({ where: { userId } });
}

// ─── Refresh Tokens ───────────────────────────────────────────────────────────

export async function createRefreshToken(userId: string, token: string, expiresAt: Date) {
  return prisma.refreshToken.create({
    data: { userId, token, expiresAt },
  });
}

export async function findRefreshToken(token: string) {
  return prisma.refreshToken.findUnique({
    where: { token },
    include: { user: { include: { profile: true } } },
  });
}

export async function deleteRefreshToken(token: string) {
  return prisma.refreshToken.deleteMany({ where: { token } });
}

export async function deleteAllRefreshTokens(userId: string) {
  return prisma.refreshToken.deleteMany({ where: { userId } });
}

// ─── Password Reset Tokens ────────────────────────────────────────────────────

export async function createPasswordResetToken(userId: string, code: string, expiresAt: Date) {
  // Delete any existing reset tokens for this user first
  await prisma.passwordResetToken.deleteMany({ where: { userId } });

  return prisma.passwordResetToken.create({
    data: { userId, code, expiresAt },
  });
}

export async function findPasswordResetToken(userId: string, code: string) {
  return prisma.passwordResetToken.findFirst({
    where: {
      userId,
      code,
      expiresAt: { gt: new Date() },
    },
  });
}

export async function deletePasswordResetToken(id: string) {
  return prisma.passwordResetToken.delete({ where: { id } });
}

export async function deleteAllPasswordResetTokens(userId: string) {
  return prisma.passwordResetToken.deleteMany({ where: { userId } });
}
