import { Router } from "express";
import { validate } from "../../middlewares/validation.middleware.js";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as controller from "./auth.controller.js";
import {
  registerSchema,
  loginSchema,
  verifyEmailSchema,
  resendCodeSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  refreshTokenSchema,
  logoutSchema,
} from "./auth.schema.js";

const router = Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user and send a verification email
 * @access  Public
 */
router.post("/register", validate(registerSchema), controller.register);

/**
 * @route   POST /api/auth/verify-email
 * @desc    Verify email with 6-digit OTP code
 * @access  Public
 */
router.post("/verify-email", validate(verifyEmailSchema), controller.verifyEmail);

/**
 * @route   POST /api/auth/resend-code
 * @desc    Resend email verification code
 * @access  Public
 */
router.post("/resend-code", validate(resendCodeSchema), controller.resendCode);

/**
 * @route   POST /api/auth/login
 * @desc    Login and receive access + refresh tokens
 * @access  Public
 */
router.post("/login", validate(loginSchema), controller.login);

/**
 * @route   POST /api/auth/refresh-token
 * @desc    Rotate refresh token and get a new access token
 * @access  Public
 */
router.post("/refresh-token", validate(refreshTokenSchema), controller.refreshToken);

/**
 * @route   POST /api/auth/forgot-password
 * @desc    Send a 6-digit password reset code to email
 * @access  Public
 */
router.post("/forgot-password", validate(forgotPasswordSchema), controller.forgotPassword);

/**
 * @route   POST /api/auth/reset-password
 * @desc    Reset password using the 6-digit code
 * @access  Public
 */
router.post("/reset-password", validate(resetPasswordSchema), controller.resetPassword);

/**
 * @route   POST /api/auth/logout
 * @desc    Invalidate refresh token
 * @access  Public (token optional — always succeeds)
 */
router.post("/logout", validate(logoutSchema), controller.logout);

/**
 * @route   PUT /api/auth/change-password
 * @desc    Change password when authenticated (requires currentPassword)
 * @access  Private
 */
router.put("/change-password", authenticate, controller.changePassword);

export default router;
