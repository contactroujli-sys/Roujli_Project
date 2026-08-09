import jwt from "jsonwebtoken";
const ACCESS_SECRET = process.env.JWT_SECRET || "roujli_super_secret_key_2026";
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || "roujli_refresh_secret_key_2026";
export function generateAccessToken(payload) {
    return jwt.sign(payload, ACCESS_SECRET, {
        expiresIn: "15m",
    });
}
export function generateRefreshToken(payload) {
    return jwt.sign(payload, REFRESH_SECRET, {
        expiresIn: "7d",
    });
}
export function verifyAccessToken(token) {
    return jwt.verify(token, ACCESS_SECRET);
}
//# sourceMappingURL=jwt.js.map