import type { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/AppError.js";

export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction
) {
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