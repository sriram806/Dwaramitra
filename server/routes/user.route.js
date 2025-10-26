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
    deleteAccount,
    guardCheckIn,
    guardCheckOut,
    getGuardsOnDuty,
    getGuardActivity,
    assignShiftAndGate,
    getGuardsUnderSupervision,
    updateGuardDetails,
    getGuardActivityReport,
    getAllGuards
} from '../controllers/user.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { authorize } from '../middleware/authorize.middleware.js';

const userRoute = express.Router();

userRoute.get('/profile', authenticate, getProfile);
userRoute.put('/profile', authenticate, updateProfile);
userRoute.get('/all', authenticate, authorize(['admin', 'security officer']), getAllUsers);
userRoute.put('/role/:userId', authenticate, authorize(['admin']), updateUserRole);
userRoute.put('/roles/bulk', authenticate, authorize(['admin']), bulkUpdateUserRoles);
userRoute.put('/designation/:userId', authenticate, authorize(['admin', 'security officer']), updateUserDesignation);
userRoute.put('/verify/:userId', authenticate, authorize(['admin', 'security officer']), verifyUserAccount);
userRoute.put('/assign-shift-gate/:userId', authenticate, authorize(['admin', 'security officer']), assignShiftAndGate);
userRoute.put('/change-password', authenticate, changePassword);
userRoute.delete('/delete-account', authenticate, deleteAccount);
userRoute.post('/guard/check-in', authenticate, authorize(['guard', 'security officer']), guardCheckIn);
userRoute.post('/guard/check-out', authenticate, authorize(['guard', 'security officer']), guardCheckOut);
userRoute.get('/guards/on-duty', authenticate, authorize(['admin', 'security officer']), getGuardsOnDuty);
userRoute.get('/guard/activity', authenticate, authorize(['admin', 'security officer']), getGuardActivity);
userRoute.get('/guards/manage', authenticate, authorize(['security officer']), getGuardsUnderSupervision);
userRoute.put('/guards/update/:guardId', authenticate, authorize(['security officer']), updateGuardDetails);
userRoute.get('/guards/activity-report', authenticate, authorize(['security officer']), getGuardActivityReport);
userRoute.get('/guards/all', authenticate, authorize(['admin', 'security officer']), getAllGuards);

export default userRoute;