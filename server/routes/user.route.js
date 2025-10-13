import express from 'express';
import { getProfile, updateProfile, getSavedItems, addSavedItem, removeSavedItem} from '../controllers/user.controller.js';
import isAuthenticated from '../middleware/isAuthenticated.js';

const userRoute = express.Router();

userRoute.get('/profile',isAuthenticated, getProfile);
userRoute.put('/profile',isAuthenticated, updateProfile);

userRoute.post('/saved-items', isAuthenticated, addSavedItem);
userRoute.get('/saved-items', isAuthenticated, getSavedItems);
userRoute.delete('/saved-items/:itemId', isAuthenticated, removeSavedItem);

export default userRoute;