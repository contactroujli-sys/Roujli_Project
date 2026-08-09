import * as service from "./businesses.services.js";
export async function getBusinesses(req, res, next) {
    try {
        const { search, categoryId, sort, page, limit } = req.query;
        const userId = req.userId;
        const result = await service.getBusinesses({
            search: search,
            categoryId: categoryId,
            sort: sort,
            page: page ? parseInt(page) : 1,
            limit: limit ? parseInt(limit) : 20,
        }, userId);
        res.status(200).json({
            success: true,
            data: result,
        });
    }
    catch (err) {
        next(err);
    }
}
export async function getBusinessById(req, res, next) {
    try {
        const id = req.params.id;
        const userId = req.userId;
        const business = await service.getBusinessById(id, userId);
        if (!business) {
            return res.status(404).json({
                success: false,
                message: "Business not found",
            });
        }
        res.status(200).json({
            success: true,
            data: business,
        });
    }
    catch (err) {
        next(err);
    }
}
export async function toggleSave(req, res, next) {
    try {
        const id = req.params.id;
        const userId = req.userId;
        const result = await service.toggleSave(userId, id);
        res.status(200).json({
            success: true,
            data: result,
        });
    }
    catch (err) {
        next(err);
    }
}
export async function toggleFollow(req, res, next) {
    try {
        const id = req.params.id;
        const userId = req.userId;
        const result = await service.toggleFollow(userId, id);
        res.status(200).json({
            success: true,
            data: result,
        });
    }
    catch (err) {
        next(err);
    }
}
export async function getSaved(req, res, next) {
    try {
        const userId = req.userId;
        const saved = await service.getSaved(userId);
        res.status(200).json({
            success: true,
            data: saved,
        });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=businesses.controller.js.map