"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentStatus = exports.PaymentMethod = exports.PriceType = exports.AdditionalService = exports.MainService = exports.OrderStatus = void 0;
var OrderStatus;
(function (OrderStatus) {
    OrderStatus["PENDING"] = "pending";
    OrderStatus["CONFIRMED"] = "confirmed";
    OrderStatus["PICKUP_SCHEDULED"] = "pickup_scheduled";
    OrderStatus["PICKED_UP"] = "picked_up";
    OrderStatus["IN_FACILITY"] = "in_facility";
    OrderStatus["PROCESSING"] = "processing";
    OrderStatus["READY_FOR_DELIVERY"] = "ready_for_delivery";
    OrderStatus["OUT_FOR_DELIVERY"] = "out_for_delivery";
    OrderStatus["DELIVERED"] = "delivered";
    OrderStatus["CANCELLED"] = "cancelled";
})(OrderStatus || (exports.OrderStatus = OrderStatus = {}));
var MainService;
(function (MainService) {
    MainService["WASH_AND_IRON"] = "wash_and_iron";
    MainService["WASH_ONLY"] = "wash_only";
    MainService["IRON_ONLY"] = "iron_only";
    MainService["PICKUP_DELIVERY"] = "pickup_delivery";
    MainService["PRESSING"] = "pressing";
    MainService["DRY_CLEANING"] = "dry_cleaning";
    MainService["IRONING"] = "ironing";
})(MainService || (exports.MainService = MainService = {}));
var AdditionalService;
(function (AdditionalService) {
    AdditionalService["DRY_CLEANING"] = "dry_cleaning";
    AdditionalService["STAIN_REMOVAL"] = "stain_removal";
    AdditionalService["DYEING"] = "dyeing";
    AdditionalService["STARCHING"] = "starching";
    AdditionalService["DUST_TREATMENT"] = "dust_treatment";
    AdditionalService["ANTI_YELLOW"] = "anti_yellow";
})(AdditionalService || (exports.AdditionalService = AdditionalService = {}));
var PriceType;
(function (PriceType) {
    PriceType["STANDARD"] = "standard";
    PriceType["BASIC"] = "basic";
})(PriceType || (exports.PriceType = PriceType = {}));
var PaymentMethod;
(function (PaymentMethod) {
    PaymentMethod["CASH"] = "cash";
    PaymentMethod["CARD"] = "card";
    PaymentMethod["MOBILE_MONEY"] = "mobile_money";
})(PaymentMethod || (exports.PaymentMethod = PaymentMethod = {}));
var PaymentStatus;
(function (PaymentStatus) {
    PaymentStatus["PENDING"] = "pending";
    PaymentStatus["COMPLETED"] = "completed";
    PaymentStatus["FAILED"] = "failed";
})(PaymentStatus || (exports.PaymentStatus = PaymentStatus = {}));
