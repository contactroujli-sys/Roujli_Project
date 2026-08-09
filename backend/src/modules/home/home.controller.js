import * as homeService from "./home.services.js";
// ─── GET /api/home ─────────────────────────────────────────────────────
export async function getHomeData(req, res, next) {
    try {
        const userId = req.userId; // From auth middleware (optional)
        const data = await homeService.getHomeData(userId);
        res.status(200).json({
            success: true,
            data,
        });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=home.controller.js.map