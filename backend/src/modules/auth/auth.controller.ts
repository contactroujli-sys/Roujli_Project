import type { Request, Response, NextFunction } from "express";
import * as authService from "./auth.services.js";

// ─── POST /api/auth/register ──────────────────────────────────────────────────

export async function register(req: Request, res: Response, next: NextFunction) {
  try {
    await authService.register(req.body);
    res.status(201).json({
      success: true,
      message: "Account created successfully. Please check your email for a verification code.",
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/verify-email ──────────────────────────────────────────────

export async function verifyEmail(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await authService.verifyEmail(req.body);
    res.status(200).json({
      success: true,
      message: "Email verified successfully.",
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/resend-code ───────────────────────────────────────────────

export async function resendCode(req: Request, res: Response, next: NextFunction) {
  try {
    await authService.resendCode(req.body);
    res.status(200).json({
      success: true,
      message: "If this email is registered, a new verification code has been sent.",
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/login ─────────────────────────────────────────────────────

export async function login(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await authService.login(req.body);
    res.status(200).json({
      success: true,
      message: "Logged in successfully.",
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/refresh-token ─────────────────────────────────────────────

export async function refreshToken(req: Request, res: Response, next: NextFunction) {
  try {
    const tokens = await authService.refreshToken(req.body);
    res.status(200).json({
      success: true,
      data: tokens,
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/forgot-password ──────────────────────────────────────────

export async function forgotPassword(req: Request, res: Response, next: NextFunction) {
  try {
    await authService.forgotPassword(req.body);
    res.status(200).json({
      success: true,
      message: "If this email is registered, a password reset code has been sent.",
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/reset-password ───────────────────────────────────────────

export async function resetPassword(req: Request, res: Response, next: NextFunction) {
  try {
    await authService.resetPassword(req.body);
    res.status(200).json({
      success: true,
      message: "Password reset successfully. Please log in with your new password.",
    });
  } catch (err) {
    next(err);
  }
}

// ─── POST /api/auth/logout ────────────────────────────────────────────────────

export async function logout(req: Request, res: Response, next: NextFunction) {
  try {
    await authService.logout(req.body.refreshToken);
    res.status(200).json({
      success: true,
      message: "Logged out successfully.",
    });
  } catch (err) {
    next(err);
  }
}

// ─── PUT /api/auth/change-password ───────────────────────────────────────────

export async function changePassword(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ success: false, message: "Unauthorized." });
    const { currentPassword, newPassword } = req.body;
    await authService.changePassword(userId, currentPassword, newPassword);
    res.status(200).json({ success: true, message: "Password changed successfully." });
  } catch (err) {
    next(err);
  }
}
