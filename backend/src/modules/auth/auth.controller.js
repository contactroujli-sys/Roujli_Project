import * as authService from "./auth.services.js";
// ─── POST /api/auth/register ──────────────────────────────────────────────────
export async function register(req, res, next) {
    try {
        await authService.register(req.body);
        res.status(201).json({
            success: true,
            message: "Account created successfully. Please check your email for a verification code.",
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/verify-email ──────────────────────────────────────────────
export async function verifyEmail(req, res, next) {
    try {
        const result = await authService.verifyEmail(req.body);
        res.status(200).json({
            success: true,
            message: "Email verified successfully.",
            data: result,
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/resend-code ───────────────────────────────────────────────
export async function resendCode(req, res, next) {
    try {
        await authService.resendCode(req.body);
        res.status(200).json({
            success: true,
            message: "If this email is registered, a new verification code has been sent.",
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/login ─────────────────────────────────────────────────────
export async function login(req, res, next) {
    try {
        const result = await authService.login(req.body);
        res.status(200).json({
            success: true,
            message: "Logged in successfully.",
            data: result,
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/refresh-token ─────────────────────────────────────────────
export async function refreshToken(req, res, next) {
    try {
        const tokens = await authService.refreshToken(req.body);
        res.status(200).json({
            success: true,
            data: tokens,
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/forgot-password ──────────────────────────────────────────
export async function forgotPassword(req, res, next) {
    try {
        await authService.forgotPassword(req.body);
        res.status(200).json({
            success: true,
            message: "If this email is registered, a password reset code has been sent.",
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/reset-password ───────────────────────────────────────────
export async function resetPassword(req, res, next) {
    try {
        await authService.resetPassword(req.body);
        res.status(200).json({
            success: true,
            message: "Password reset successfully. Please log in with your new password.",
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── POST /api/auth/logout ────────────────────────────────────────────────────
export async function logout(req, res, next) {
    try {
        await authService.logout(req.body.refreshToken);
        res.status(200).json({
            success: true,
            message: "Logged out successfully.",
        });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=auth.controller.js.map