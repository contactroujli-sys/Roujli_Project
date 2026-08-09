import { Role } from "@prisma/client";

// ─── Input Types ─────────────────────────────────────────────────────────────

export interface RegisterInput {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  role: Role;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface VerifyEmailInput {
  email: string;
  code: string;
}

export interface ResendCodeInput {
  email: string;
}

export interface ForgotPasswordInput {
  email: string;
}

export interface ResetPasswordInput {
  email: string;
  code: string;
  newPassword: string;
}

export interface RefreshTokenInput {
  refreshToken: string;
}

export interface LogoutInput {
  refreshToken: string;
}

// ─── Response Types ───────────────────────────────────────────────────────────

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthUser {
  id: string;
  email: string;
  role: Role;
  isVerified: boolean;
  profile: {
    firstName: string;
    lastName: string;
    avatar: string | null;
  } | null;
}

export interface AuthResponse {
  user: AuthUser;
  tokens: AuthTokens;
}
