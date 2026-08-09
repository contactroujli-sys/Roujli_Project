import { AppError } from "../utils/AppError.js";
export function errorHandler(err, _req, res, _next) {
    if (err instanceof AppError) {
        return res.status(err.status).json({
            success: false,
            message: err.message,
        });
    }
    // Unknown / unexpected errors
    console.error("[UnhandledError]", err);
    return res.status(500).json({
        success: false,
        message: "Internal Server Error",
    });
}
//# sourceMappingURL=error.middleware.js.map