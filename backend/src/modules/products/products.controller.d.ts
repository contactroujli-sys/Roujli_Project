import type { Request, Response, NextFunction } from "express";
export declare function createProduct(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function getProducts(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
export declare function updateProduct(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function deleteProduct(req: Request, res: Response, next: NextFunction): Promise<void>;
//# sourceMappingURL=products.controller.d.ts.map