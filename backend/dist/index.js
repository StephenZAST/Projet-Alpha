"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const users_1 = __importDefault(require("./routes/users"));
const config_1 = require("./config");
const app = (0, express_1.default)();
const port = config_1.config.port || 3001;
app.use(express_1.default.json());
app.use('/api/users', users_1.default);
app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
});
