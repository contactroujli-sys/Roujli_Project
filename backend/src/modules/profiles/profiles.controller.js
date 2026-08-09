import * as profilesService from "./profiles.services.js";
// ─── GET /api/profile ───────────────────────────────────────────────────
export async function getProfileData(req, res, next) {
    try {
        const userId = req.userId; // From auth middleware
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "User not authenticated",
            });
        }
        const data = await profilesService.getProfileData(userId);
        res.status(200).json({
            success: true,
            data,
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── PUT /api/profile ───────────────────────────────────────────────────
export async function updateProfileData(req, res, next) {
    try {
        const userId = req.userId; // From auth middleware
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "User not authenticated",
            });
        }
        const data = await profilesService.updateProfileData(userId, req.body);
        res.status(200).json({
            success: true,
            data,
        });
    }
    catch (err) {
        next(err);
    }
}
// ─── PUT /api/profile/business ───────────────────────────────────────────
export async function updateBusinessData(req, res, next) {
    try {
        const userId = req.userId; // From auth middleware
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "User not authenticated",
            });
        }
        const data = await profilesService.updateBusinessData(userId, req.body);
        res.status(200).json({
            success: true,
            data,
        });
    }
    catch (err) {
        next(err);
    }
}
export async function deleteBusiness(req, res, next) {
    try {
        const userId = req.userId;
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "User not authenticated",
            });
        }
        const result = await profilesService.deleteBusiness(userId);
        if (result.count === 0) {
            return res.status(404).json({
                success: false,
                message: "No business found to delete",
            });
        }
        res.status(200).json({
            success: true,
            message: "Business deleted successfully",
        });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=profiles.controller.js.map