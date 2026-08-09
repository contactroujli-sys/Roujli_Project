import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
const options = {
    definition: {
        openapi: "3.0.0",
        info: {
            title: "ROUJLI API",
            version: "1.0.0",
            description: "Business Growth Platform API",
        },
        servers: [
            {
                url: "http://localhost:5000/api",
            },
        ],
    },
    apis: [],
};
export const swaggerSpec = swaggerJsdoc(options);
export { swaggerUi };
//# sourceMappingURL=swagger.js.map