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
Object.defineProperty(exports, "__esModule", { value: true });
exports.createUser = createUser;
const firestore_1 = require("firebase/firestore");
function createUser(user) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const firestore = (0, firestore_1.getFirestore)();
            const usersCollectionRef = (0, firestore_1.collection)(firestore, "users");
            const newUser = yield (0, firestore_1.addDoc)(usersCollectionRef, {
                uid: user.uid,
                email: user.email,
                displayName: user.displayName,
                phoneNumber: user.phoneNumber,
                address: user.address,
                role: user.role,
                affiliateId: user.affiliateId,
                creationDate: firestore_1.Timestamp.now(),
                lastLogin: firestore_1.Timestamp.now(),
            });
            const newUserData = Object.assign(Object.assign({}, user), { id: newUser.id });
            return newUserData;
        }
        catch (error) {
            console.error("Error creating user:", error);
            return null;
        }
    });
}
