import * as service from "./products.services.js";
export async function createProduct(req, res, next) {
    try {
        const userId = req.userId;
        const { name, description, price, image } = req.body;
        const data = { name: String(name), price: parseFloat(price) };
        if (description !== undefined)
            data.description = String(description);
        if (image !== undefined)
            data.image = String(image);
        const product = await service.createProduct(userId, data);
        res.status(201).json({ success: true, data: product });
    }
    catch (err) {
        next(err);
    }
}
export async function getProducts(req, res, next) {
    try {
        const businessId = req.query.businessId;
        if (!businessId) {
            return res.status(400).json({ success: false, message: "businessId query parameter is required" });
        }
        const products = await service.getProducts(businessId);
        res.status(200).json({ success: true, data: products });
    }
    catch (err) {
        next(err);
    }
}
export async function updateProduct(req, res, next) {
    try {
        const userId = req.userId;
        const id = req.params.id;
        const { name, description, price, image } = req.body;
        const data = {};
        if (name !== undefined)
            data.name = String(name);
        if (description !== undefined)
            data.description = String(description);
        if (price !== undefined)
            data.price = parseFloat(price);
        if (image !== undefined)
            data.image = String(image);
        const product = await service.updateProduct(userId, id, data);
        res.status(200).json({ success: true, data: product });
    }
    catch (err) {
        next(err);
    }
}
export async function deleteProduct(req, res, next) {
    try {
        const userId = req.userId;
        const id = req.params.id;
        await service.deleteProduct(userId, id);
        res.status(200).json({ success: true, message: "Product deleted" });
    }
    catch (err) {
        next(err);
    }
}
//# sourceMappingURL=products.controller.js.map