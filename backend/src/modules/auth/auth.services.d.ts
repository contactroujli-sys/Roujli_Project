import type { RegisterInput, LoginInput, VerifyEmailInput, ResendCodeInput, ForgotPasswordInput, ResetPasswordInput, RefreshTokenInput, AuthResponse, AuthTokens } from "./auth.types.js";
export declare function register(input: RegisterInput): Promise<void>;
export declare function verifyEmail(input: VerifyEmailInput): Promise<AuthResponse>;
export declare function resendCode(input: ResendCodeInput): Promise<void>;
export declare function login(input: LoginInput): Promise<AuthResponse>;
export declare function refreshToken(input: RefreshTokenInput): Promise<AuthTokens>;
export declare function forgotPassword(input: ForgotPasswordInput): Promise<void>;
export declare function resetPassword(input: ResetPasswordInput): Promise<void>;
export declare function logout(refreshTokenStr: string): Promise<void>;
//# sourceMappingURL=auth.services.d.ts.map