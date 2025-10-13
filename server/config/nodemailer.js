import nodemailer from 'nodemailer';
import ejs from 'ejs';
import path from 'path';
import { fileURLToPath } from 'url';

import { SMTP_HOST, SMTP_PASS, SMTP_PORT, SMTP_SERVICE, SMTP_EMAIL } from './env.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const sendMail = async (options) => {
    const transporter = nodemailer.createTransport({
        host: SMTP_HOST,
        port: SMTP_PORT,
        service: SMTP_SERVICE,
        auth: {
            user: SMTP_EMAIL,
            pass: SMTP_PASS
        }
    });

    const { email, subject, template, data } = options;

    const templatePath = path.join(__dirname, '../mails', `${template}.ejs`);
    const html = await ejs.renderFile(templatePath, data);
    const mailOptions = {
        from: SMTP_EMAIL,
        to: email,
        subject,
        html
    };
    try {
        await transporter.sendMail(mailOptions);
    } catch (error) {
        console.error('Error sending email:', error);
    }
}

export default sendMail;
