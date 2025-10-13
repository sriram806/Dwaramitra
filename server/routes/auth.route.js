import express from 'express';
import {
  registration,
  login,
  logout,
  VerifyOTP,
  ResendOTP,
  forgotPassword,
  resetPassword,
  changePassword
} from "../controllers/auth.controller.js";
import isAuthenticated from '../middleware/isAuthenticated.js';

const authRoute = express.Router();

authRoute.post('/register', registration);
authRoute.post('/verify-otp', isAuthenticated, VerifyOTP);
authRoute.post('/resend-otp', isAuthenticated, ResendOTP); 
authRoute.post('/login', login);
authRoute.post('/logout', isAuthenticated, logout); 
authRoute.post('/forgot-password', forgotPassword);
authRoute.post('/reset-password', resetPassword);
authRoute.put('/change-password', isAuthenticated, changePassword);

export default authRoute;
