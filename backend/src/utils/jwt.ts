import jwt from "jsonwebtoken";

const ACCESS_SECRET = process.env.JWT_SECRET || "roujli_super_secret_key_2026";
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || "roujli_refresh_secret_key_2026";

const ACCESS_EXPIRES_IN = (process.env.JWT_ACCESS_EXPIRES_IN || process.env.JWT_EXPIRES_IN || "1h") as string;
const REFRESH_EXPIRES_IN = (process.env.JWT_REFRESH_EXPIRES_IN || "30d") as string;

export function generateAccessToken(payload: object) {
  return jwt.sign(payload, ACCESS_SECRET, {
    expiresIn: ACCESS_EXPIRES_IN,
  } as jwt.SignOptions);
}

export function generateRefreshToken(payload: object) {
  return jwt.sign(payload, REFRESH_SECRET, {
    expiresIn: REFRESH_EXPIRES_IN,
  } as jwt.SignOptions);
}

export function verifyAccessToken(token: string) {
  return jwt.verify(token, ACCESS_SECRET);
}