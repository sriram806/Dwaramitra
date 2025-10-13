import { config } from "dotenv";

config({ path: `.env.${process.env.NODE_ENV || 'development'}.local || .env` });

export const {
    PORT,
    NODE_ENV,
    MONGO_URI,
    JWT_SECRET,
    JWT_EXPIRES_IN,
    SMTP_HOST,
    SMTP_PORT,
    SMTP_PASS,
    SMTP_SERVICE,
    SMTP_EMAIL,
    FRONTEND_URL,
    ORIGIN,
    CLOUD_NAME,
    CLOUD_API_KEY,
    CLOUD_SECRET_KEY,
    REDIS_URL,
    ACCESS_TOKEN_EXPIRES_IN,
    REFRESH_TOKEN_EXPIRES_IN,
    ACTIVATION_SECRET,
    ACCESS_TOKEN,
    REFRESH_TOKEN
} = process.env;