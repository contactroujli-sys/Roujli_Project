import type { Request, Response, NextFunction } from "express";
export declare function register(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function verifyEmail(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function resendCode(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function login(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function refreshToken(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function forgotPassword(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function resetPassword(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function logout(req: Request, res: Response, next: NextFunction): Promise<void>;
//# sourceMappingURL=auth.controller.d.ts.map