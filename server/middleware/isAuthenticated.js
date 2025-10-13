import jwt from "jsonwebtoken";
import { JWT_SECRET } from "../config/env.js";
import catchAsyncErrors from "./catchAsyncErrors.js";
import User from "../models/user.model.js";

const isAuthenticated = catchAsyncErrors(async (req, res, next) => {
    try {
        const token = req.cookies.token || req.headers.authorization?.split(" ")[1];
        if (!token) {
            return res.status(401).json({ success: false, message: "Access token missing. Please login." });
        }   
        
        const decoded = jwt.verify(token, JWT_SECRET);

        const currentUser = await User.findById(decoded.id);
        if (!currentUser) {
            return res.status(401).json({ success: false, message: "User not found." });
        }

        req.user = currentUser;
        next();
    } catch (error) {
        console.error(" Internal isAuthenticated middleware error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error.",
        });
    }
});

export default isAuthenticated;