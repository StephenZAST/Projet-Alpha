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
exports.AddressService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class AddressService {
    static getAddressById(addressId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                console.log('Getting address by ID:', addressId);
                const address = yield prisma.addresses.findUnique({
                    where: { id: addressId }
                });
                console.log('Found address:', address);
                if (!address)
                    return null;
                return {
                    id: address.id,
                    user_id: address.userId || '',
                    name: address.name || '',
                    street: address.street,
                    city: address.city,
                    postal_code: address.postal_code || '',
                    gps_latitude: address.gps_latitude ? Number(address.gps_latitude) : undefined,
                    gps_longitude: address.gps_longitude ? Number(address.gps_longitude) : undefined,
                    is_default: address.is_default || false,
                    created_at: address.created_at || new Date(),
                    updated_at: address.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('Get address by ID error:', error);
                throw error;
            }
        });
    }
    static createAddress(userId_1, name_1, street_1, city_1, postalCode_1, gpsLatitude_1, gpsLongitude_1) {
        return __awaiter(this, arguments, void 0, function* (userId, name, street, city, postalCode, gpsLatitude, gpsLongitude, isDefault = false) {
            try {
                // Si isDefault, mettre toutes les autres adresses de ce user à false
                if (isDefault) {
                    yield prisma.addresses.updateMany({
                        where: { userId },
                        data: { is_default: false }
                    });
                }
                const address = yield prisma.addresses.create({
                    data: {
                        userId: userId,
                        name,
                        street,
                        city,
                        postal_code: postalCode,
                        gps_latitude: gpsLatitude ? Number(gpsLatitude) : null,
                        gps_longitude: gpsLongitude ? Number(gpsLongitude) : null,
                        is_default: isDefault,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                return {
                    id: address.id,
                    user_id: address.userId || '',
                    name: address.name || '',
                    street: address.street,
                    city: address.city,
                    postal_code: address.postal_code || '',
                    gps_latitude: address.gps_latitude ? Number(address.gps_latitude) : undefined,
                    gps_longitude: address.gps_longitude ? Number(address.gps_longitude) : undefined,
                    is_default: address.is_default || false,
                    created_at: address.created_at || new Date(),
                    updated_at: address.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('Address creation error:', error);
                throw error;
            }
        });
    }
    static getAllAddresses(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const addresses = yield prisma.addresses.findMany({
                    where: { userId: userId }
                });
                return addresses.map(address => ({
                    id: address.id,
                    user_id: address.userId || '',
                    name: address.name || '',
                    street: address.street,
                    city: address.city,
                    postal_code: address.postal_code || '',
                    gps_latitude: address.gps_latitude ? Number(address.gps_latitude) : undefined,
                    gps_longitude: address.gps_longitude ? Number(address.gps_longitude) : undefined,
                    is_default: address.is_default || false,
                    created_at: address.created_at || new Date(),
                    updated_at: address.updated_at || new Date()
                }));
            }
            catch (error) {
                console.error('Get all addresses error:', error);
                throw error;
            }
        });
    }
    static updateAddress(addressId_1, userId_1, name_1, street_1, city_1, postalCode_1, gpsLatitude_1, gpsLongitude_1) {
        return __awaiter(this, arguments, void 0, function* (addressId, userId, name, street, city, postalCode, gpsLatitude, gpsLongitude, isDefault = false) {
            console.log('Updating address with data:', {
                addressId,
                userId,
                name,
                street,
                city,
                postalCode,
                gpsLatitude,
                gpsLongitude,
                isDefault
            });
            // Vérifier d'abord si l'adresse existe et appartient à l'utilisateur
            const existingAddress = yield prisma.addresses.findFirst({
                where: {
                    id: addressId,
                    userId: userId
                }
            });
            if (!existingAddress) {
                throw new Error('Address not found or unauthorized');
            }
            // Si isDefault, mettre toutes les autres adresses de ce user à false
            if (isDefault) {
                yield prisma.addresses.updateMany({
                    where: { userId, NOT: { id: addressId } },
                    data: { is_default: false }
                });
            }
            const updatedAddress = yield prisma.addresses.update({
                where: {
                    id: addressId
                },
                data: {
                    name,
                    street,
                    city,
                    postal_code: postalCode,
                    gps_latitude: gpsLatitude ? Number(gpsLatitude) : null,
                    gps_longitude: gpsLongitude ? Number(gpsLongitude) : null,
                    is_default: isDefault,
                    updated_at: new Date()
                }
            });
            console.log('Address updated successfully:', updatedAddress);
            return {
                id: updatedAddress.id,
                user_id: updatedAddress.userId || '',
                name: updatedAddress.name || '',
                street: updatedAddress.street,
                city: updatedAddress.city,
                postal_code: updatedAddress.postal_code || '',
                gps_latitude: updatedAddress.gps_latitude ? Number(updatedAddress.gps_latitude) : undefined,
                gps_longitude: updatedAddress.gps_longitude ? Number(updatedAddress.gps_longitude) : undefined,
                is_default: updatedAddress.is_default || false,
                created_at: updatedAddress.created_at || new Date(),
                updated_at: updatedAddress.updated_at || new Date()
            };
        });
    }
    static deleteAddress(addressId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.addresses.deleteMany({
                    where: {
                        id: addressId,
                        userId: userId
                    }
                });
            }
            catch (error) {
                console.error('Delete address error:', error);
                throw error;
            }
        });
    }
}
exports.AddressService = AddressService;
