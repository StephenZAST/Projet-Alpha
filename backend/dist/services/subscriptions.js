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
exports.getUserSubscription = exports.deleteSubscription = exports.updateSubscription = exports.createSubscription = exports.getSubscriptions = void 0;
const firebase_1 = require("./firebase");
const errors_1 = require("../utils/errors");
function getSubscriptions() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const subscriptionsSnapshot = yield firebase_1.db.collection('subscriptions').get();
            return subscriptionsSnapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to fetch subscriptions', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.getSubscriptions = getSubscriptions;
function createSubscription(subscriptionData) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const subscriptionRef = yield firebase_1.db.collection('subscriptions').add(subscriptionData);
            return Object.assign(Object.assign({}, subscriptionData), { id: subscriptionRef.id });
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to create subscription', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.createSubscription = createSubscription;
function updateSubscription(subscriptionId, subscriptionData) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const subscriptionRef = firebase_1.db.collection('subscriptions').doc(subscriptionId);
            yield subscriptionRef.update(subscriptionData);
            const updatedSubscription = yield subscriptionRef.get();
            return Object.assign({ id: subscriptionId }, updatedSubscription.data());
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to update subscription', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.updateSubscription = updateSubscription;
function deleteSubscription(subscriptionId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield firebase_1.db.collection('subscriptions').doc(subscriptionId).delete();
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to delete subscription', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.deleteSubscription = deleteSubscription;
function getUserSubscription(userId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const userSubSnapshot = yield firebase_1.db.collection('userSubscriptions')
                .where('userId', '==', userId)
                .where('status', '==', 'active')
                .get();
            if (userSubSnapshot.empty)
                return null;
            return Object.assign({ id: userSubSnapshot.docs[0].id }, userSubSnapshot.docs[0].data());
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to fetch user subscription', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.getUserSubscription = getUserSubscription;
