import type { Request, Response, NextFunction } from "express";
export declare function createService(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function getServices(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
export declare function updateService(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function deleteService(req: Request, res: Response, next: NextFunction): Promise<void>;
//# sourceMappingURL=services.controller.d.ts.map