import { verifyAccessToken } from "../utils/jwt.js";
import { AppError } from "../utils/AppError.js";
export function authenticate(req, res, next) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return next(new AppError("Authentication required. Please log in.", 401));
    }
    const token = authHeader.slice(7);
    try {
        const decoded = verifyAccessToken(token);
        req.user = decoded;
        req.userId = decoded.userId; // Also set userId directly for easier access
        next();
    }
    catch {
        next(new AppError("Invalid or expired access token. Please log in again.", 401));
    }
}
export function optionalAuth(req, res, next) {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith("Bearer ")) {
        const token = authHeader.slice(7);
        try {
            const decoded = verifyAccessToken(token);
            req.user = decoded;
            req.userId = decoded.userId;
        }
        catch {
            // Invalid token - continue without authentication
        }
    }
    next();
}
//# sourceMappingURL=auth.middleware.js.map