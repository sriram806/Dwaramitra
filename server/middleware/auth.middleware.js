import jwt from 'jsonwebtoken';
import { ErrorHandler } from '../utils/error.js';
import User from '../models/user.model.js';

// Simple token verification function (for Socket.IO auth)
export const verifyToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

export const authenticate = async (req, res, next) => {
  try {
    // Get token from header
    const token = req.cookies?.access_token || 
                 req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return next(new ErrorHandler('Authentication required', 401));
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Find user and attach to request
    const user = await User.findById(decoded.id).select('-password');
    
    if (!user) {
      return next(new ErrorHandler('User not found', 404));
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return next(new ErrorHandler('Invalid token', 401));
    } else if (error.name === 'TokenExpiredError') {
      return next(new ErrorHandler('Token expired', 401));
    }
    next(error);
  }
};

export const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(
        new ErrorHandler(
          `Role (${req.user.role}) is not allowed to access this resource`,
          403
        )
      );
    }
    next();
  };
};
