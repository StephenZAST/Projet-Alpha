"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const address_controller_1 = require("../controllers/address.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken); // Cette ligne exige un token JWT
// Route PATCH standard REST pour mise à jour d'une adresse
router.patch('/:addressId', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield address_controller_1.AddressController.updateAddress(req, res);
    }
    catch (error) {
        next(error);
    }
})));
// Routes client
router.post('/create', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Received create address request');
    console.log('Request body:', req.body);
    try {
        yield address_controller_1.AddressController.createAddress(req, res);
    }
    catch (error) {
        console.error('Error in create address route:', error);
        next(error);
    }
})));
router.get('/all', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield address_controller_1.AddressController.getAllAddresses(req, res);
    }
    catch (error) {
        next(error);
    }
})));
// Endpoint pour récupérer les adresses d'un utilisateur par son id
router.get('/user/:userId', (0, asyncHandler_1.asyncHandler)(address_controller_1.AddressController.getAddressesByUserId));
// Routes admin
router.patch('/update/:addressId', 
// Suppression de authorizeRoles
(0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield address_controller_1.AddressController.updateAddress(req, res);
    }
    catch (error) {
        next(error);
    }
})));
router.delete('/delete/:addressId', 
// Suppression de authorizeRoles pour permettre à tous les utilisateurs authentifiés
(0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield address_controller_1.AddressController.deleteAddress(req, res);
    }
    catch (error) {
        next(error);
    }
})));
exports.default = router;
