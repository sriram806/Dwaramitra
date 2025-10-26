import { ErrorHandler } from '../utils/error.js';

export const authorize = (roles = []) => {
  return (req, res, next) => {
    try {
      // If roles is a string, convert it to an array
      const requiredRoles = Array.isArray(roles) ? roles : [roles];
      
      // Check if user has required role
      if (!requiredRoles.includes(req.user.role)) {
        throw new ErrorHandler(
          `User role ${req.user.role} is not authorized to access this route`,
          403
        );
      }
      
      next();
    } catch (error) {
      next(error);
    }
  };
};
