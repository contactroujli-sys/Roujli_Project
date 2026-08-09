import type { Request, Response, NextFunction } from "express";
export declare function getBusinesses(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function getBusinessById(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
export declare function toggleSave(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function toggleFollow(req: Request, res: Response, next: NextFunction): Promise<void>;
export declare function getSaved(req: Request, res: Response, next: NextFunction): Promise<void>;
//# sourceMappingURL=businesses.controller.d.ts.map