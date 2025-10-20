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
exports.sendEmail = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
const transporter = nodemailer_1.default.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT || '587'),
    secure: process.env.EMAIL_SECURE === 'true',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});
const sendEmail = (to, code) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Attempting to send email to:', to);
    const mailOptions = {
        from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_FROM_ADDRESS}>`,
        to: to,
        subject: 'Code de réinitialisation de mot de passe',
        html: `
      <h1>Réinitialisation de mot de passe</h1>
      <p>Votre code de vérification est : <strong>${code}</strong></p>
      <p>Ce code expirera dans 15 minutes.</p>
    `
    };
    try {
        console.log('Email configuration:', {
            host: process.env.EMAIL_HOST,
            port: process.env.EMAIL_PORT,
            secure: process.env.EMAIL_SECURE === 'true',
            from: process.env.EMAIL_FROM_ADDRESS
        });
        const result = yield transporter.sendMail(mailOptions);
        console.log('Email sent successfully:', result);
        return result;
    }
    catch (error) {
        console.error('Error sending email:', error);
        throw error;
    }
});
exports.sendEmail = sendEmail;
