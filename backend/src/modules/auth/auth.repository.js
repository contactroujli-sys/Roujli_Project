import prisma from "../../config/prisma.js";
// ─── User ─────────────────────────────────────────────────────────────────────
export async function findUserByEmail(email) {
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
export async function createUser(data) {
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
export async function markUserVerified(userId) {
    return prisma.user.update({
        where: { id: userId },
        data: { isVerified: true },
    });
}
export async function updateUserPassword(userId, hashedPassword) {
    return prisma.user.update({
        where: { id: userId },
        data: { password: hashedPassword },
    });
}
// ─── Verification Codes ───────────────────────────────────────────────────────
export async function createVerificationCode(userId, code, expiresAt) {
    // Delete any existing codes for this user first
    await prisma.verificationCode.deleteMany({ where: { userId } });
    return prisma.verificationCode.create({
        data: { userId, code, expiresAt },
    });
}
export async function findVerificationCode(userId, code) {
    return prisma.verificationCode.findFirst({
        where: {
            userId,
            code,
            expiresAt: { gt: new Date() },
        },
    });
}
export async function deleteVerificationCode(id) {
    return prisma.verificationCode.delete({ where: { id } });
}
export async function deleteAllVerificationCodes(userId) {
    return prisma.verificationCode.deleteMany({ where: { userId } });
}
// ─── Refresh Tokens ───────────────────────────────────────────────────────────
export async function createRefreshToken(userId, token, expiresAt) {
    return prisma.refreshToken.create({
        data: { userId, token, expiresAt },
    });
}
export async function findRefreshToken(token) {
    return prisma.refreshToken.findUnique({
        where: { token },
        include: { user: { include: { profile: true } } },
    });
}
export async function deleteRefreshToken(token) {
    return prisma.refreshToken.deleteMany({ where: { token } });
}
export async function deleteAllRefreshTokens(userId) {
    return prisma.refreshToken.deleteMany({ where: { userId } });
}
// ─── Password Reset Tokens ────────────────────────────────────────────────────
export async function createPasswordResetToken(userId, code, expiresAt) {
    // Delete any existing reset tokens for this user first
    await prisma.passwordResetToken.deleteMany({ where: { userId } });
    return prisma.passwordResetToken.create({
        data: { userId, code, expiresAt },
    });
}
export async function findPasswordResetToken(userId, code) {
    return prisma.passwordResetToken.findFirst({
        where: {
            userId,
            code,
            expiresAt: { gt: new Date() },
        },
    });
}
export async function deletePasswordResetToken(id) {
    return prisma.passwordResetToken.delete({ where: { id } });
}
export async function deleteAllPasswordResetTokens(userId) {
    return prisma.passwordResetToken.deleteMany({ where: { userId } });
}
//# sourceMappingURL=auth.repository.js.map