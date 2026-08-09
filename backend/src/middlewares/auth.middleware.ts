import type { Request, Response, NextFunction } from "express";
import { verifyAccessToken } from "../utils/jwt.js";
import { AppError } from "../utils/AppError.js";

// Extend Express Request to carry the decoded JWT payload
declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: string;
        email: string;
        role: string;
      };
      userId?: string;
    }
  }
}

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next(new AppError("Authentication required. Please log in.", 401));
  }

  const token = authHeader.slice(7);

  try {
    const decoded = verifyAccessToken(token) as {
      userId: string;
      email: string;
      role: string;
    };
    req.user = decoded;
    req.userId = decoded.userId; // Also set userId directly for easier access
    next();
  } catch {
    next(new AppError("Invalid or expired access token. Please log in again.", 401));
  }
}

export function optionalAuth(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (authHeader && authHeader.startsWith("Bearer ")) {
    const token = authHeader.slice(7);

    try {
      const decoded = verifyAccessToken(token) as {
        userId: string;
        email: string;
        role: string;
      };
      req.user = decoded;
      req.userId = decoded.userId;
    } catch {
      // Invalid token - continue without authentication
    }
  }
  
  next();
}

export function authorizeRoles(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !req.user.role) {
      return next(new AppError("Not authenticated or role missing.", 401));
    }
    
    if (!allowedRoles.includes(req.user.role)) {
      return next(new AppError("You do not have permission to perform this action.", 403));
    }
    
    next();
  };
}
