export function notFound(req, res) {
    res.status(404).json({
        success: false,
        message: "Route Not Found",
    });
}
//# sourceMappingURL=notFound.middleware.js.map