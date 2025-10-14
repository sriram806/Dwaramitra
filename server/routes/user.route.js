import express from 'express';
import { 
    getProfile, 
    updateProfile, 
    getAllUsers,
    updateUserRole,
    bulkUpdateUserRoles,
    updateUserDesignation,
    verifyUserAccount,
    changePassword,
    deleteAccount
} from '../controllers/user.controller.js';
import isAuthenticated from '../middleware/isAuthenticated.js';

const userRoute = express.Router();

// Profile routes
userRoute.get('/profile', isAuthenticated, getProfile);
userRoute.put('/profile', isAuthenticated, updateProfile);

// Admin routes
userRoute.get('/all', isAuthenticated, getAllUsers);
userRoute.put('/role/:userId', isAuthenticated, updateUserRole);
userRoute.put('/roles/bulk', isAuthenticated, bulkUpdateUserRoles);
userRoute.put('/designation/:userId', isAuthenticated, updateUserDesignation);
userRoute.put('/verify/:userId', isAuthenticated, verifyUserAccount);
userRoute.put('/change-password', isAuthenticated, changePassword);
userRoute.delete('/delete-account', isAuthenticated, deleteAccount);


export default userRoute;