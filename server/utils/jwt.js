import {
  ACCESS_TOKEN_EXPIRES_IN,
  REFRESH_TOKEN_EXPIRES_IN,
  NODE_ENV,
} from "../config/env.js";
import redisClient from "../database/redis.js";

export const refreshTokenExpire = parseInt(REFRESH_TOKEN_EXPIRES_IN);
export const accessTokenExpire = parseInt(ACCESS_TOKEN_EXPIRES_IN);


const isProduction = NODE_ENV === "production";

export const accessTokenOptions = {
  httpOnly: true,
};

export const refreshTokenOptions = {
  httpOnly: true
};

export const sendToken = async (user, statusCode, res) => {
  try {
    const accessToken = user.SignAccessToken();
    const refreshToken = user.SignRefreshToken();

    await redisClient.set(user._id.toString(), JSON.stringify(user));

    res.cookie("access_token", accessToken, accessTokenOptions);
    res.cookie("refresh_token", refreshToken, refreshTokenOptions);
    
    const safeUser = {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
    };

    return res.status(statusCode).json({
      success: true,
      user: safeUser,
      accessToken,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: "Failed to issue tokens" });
  }
};
