export class AppError extends Error {
    status;
    constructor(message, status = 500) {
        super(message);
        this.status = status;
        this.name = "AppError";
        Object.setPrototypeOf(this, AppError.prototype);
    }
}
//# sourceMappingURL=AppError.js.map