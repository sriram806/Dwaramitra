import User from '../models/user.model.js';
import bcrypt from 'bcryptjs';

export const getAllUsers = async (req, res) => {
    try {
        if (!req.user || req.user.role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }
        
        const { page = 1, limit = 10, search = '', role = '', designation = '' } = req.query;
        
        // Build filter object
        const filter = {};
        if (search) {
            filter.$or = [
                { name: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } },
                { universityId: { $regex: search, $options: 'i' } }
            ];
        }
        if (role) filter.role = role;
        if (designation) filter.designation = designation;
        
        const users = await User.find(filter)
            .select('-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt')
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .sort({ createdAt: -1 });
        
        const total = await User.countDocuments(filter);
        
        res.status(200).json({ 
            success: true, 
            users, 
            totalPages: Math.ceil(total / limit),
            currentPage: page,
            total 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Get user profile
export const getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user._id).select('-password');
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });
        return res.status(200).json({ success: true, user });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Update user profile
export const updateProfile = async (req, res) => {
    try {
        const { 
            name, 
            email, 
            phone, 
            gender, 
            universityId, 
            department, 
            designation, 
            shift,
            avatar 
        } = req.body;
        
        const user = await User.findById(req.user._id);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });
        
        // Update fields if provided
        if (name) user.name = name;
        if (email) user.email = email;
        if (phone) user.phone = phone;
        if (gender && ['Male', 'Female'].includes(gender)) user.gender = gender;
        if (universityId) user.universityId = universityId;
        if (department) user.department = department;
        if (designation && ['Student', 'Staff', 'Faculty', 'Admin Staff', 'Visitor'].includes(designation)) {
            user.designation = designation;
        }
        if (avatar) user.avatar = avatar;
        
        await user.save();
        
        // Return user without password
        const updatedUser = await User.findById(user._id).select('-password');
        res.status(200).json({ success: true, message: "Successfully Updated", user: updatedUser });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Update user designation (for admin/authorized users)
export const updateUserDesignation = async (req, res) => {
    try {
        const { userId } = req.params;
        const { designation } = req.body;
        
        // Check if user has permission (admin or security officer)
        if (!req.user || !['admin', 'security officer'].includes(req.user.role)) {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }
        
        if (!userId) return res.status(400).json({ success: false, message: 'User ID is required' });
        if (!designation) return res.status(400).json({ success: false, message: 'Designation is required' });
        
        const ALLOWED_DESIGNATIONS = ['Student', 'Staff', 'Faculty', 'Admin Staff', 'Visitor'];
        if (!ALLOWED_DESIGNATIONS.includes(designation)) {
            return res.status(400).json({ success: false, message: 'Invalid designation' });
        }
        
        const userToUpdate = await User.findById(userId);
        if (!userToUpdate) return res.status(404).json({ success: false, message: 'Target user not found' });
        
        userToUpdate.designation = designation;
        await userToUpdate.save();
        
        res.status(200).json({ 
            success: true, 
            message: 'Designation updated successfully', 
            user: { _id: userToUpdate._id, designation: userToUpdate.designation } 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Verify user account (for admin)
export const verifyUserAccount = async (req, res) => {
    try {
        const { userId } = req.params;
        
        // Check if user has admin permission
        if (!req.user || req.user.role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }
        
        if (!userId) return res.status(400).json({ success: false, message: 'User ID is required' });
        
        const userToVerify = await User.findById(userId);
        if (!userToVerify) return res.status(404).json({ success: false, message: 'Target user not found' });
        
        userToVerify.isAccountVerified = true;
        await userToVerify.save();
        
        res.status(200).json({ 
            success: true, 
            message: 'User account verified successfully', 
            user: { _id: userToVerify._id, isAccountVerified: userToVerify.isAccountVerified } 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Update a single user's role (Admin only)
export const updateUserRole = async (req, res) => {
    try {
        if (!req.user || req.user.role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }

        const { userId } = req.params;
        const { role } = req.body;

        if (!userId) return res.status(400).json({ success: false, message: 'User ID is required' });
        if (!role) return res.status(400).json({ success: false, message: 'Role is required' });

        const ALLOWED_ROLES = ['user', 'guard', 'security officer', 'admin'];
        if (!ALLOWED_ROLES.includes(role)) {
            return res.status(400).json({ success: false, message: 'Invalid role' });
        }

        const userToUpdate = await User.findById(userId);
        if (!userToUpdate) return res.status(404).json({ success: false, message: 'Target user not found' });

        userToUpdate.role = role;
        await userToUpdate.save();

        res.status(200).json({ success: true, message: 'Role updated successfully', user: { _id: userToUpdate._id, role: userToUpdate.role } });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Bulk update roles (Admin only)
export const bulkUpdateUserRoles = async (req, res) => {
    try {
        if (!req.user || req.user.role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }

        const { updates } = req.body; // [{ userId, role }, ...]
        if (!Array.isArray(updates) || updates.length === 0) {
            return res.status(400).json({ success: false, message: 'Updates array is required' });
        }

        const ALLOWED_ROLES = ['user', 'guard', 'security officer', 'admin'];
        const results = [];
        for (const entry of updates) {
            const { userId, role } = entry || {};
            if (!userId || !role || !ALLOWED_ROLES.includes(role)) {
                results.push({ userId, success: false, message: 'Invalid data' });
                continue;
            }
            const userDoc = await User.findById(userId);
            if (!userDoc) {
                results.push({ userId, success: false, message: 'User not found' });
                continue;
            }
            userDoc.role = role;
            await userDoc.save();
            results.push({ userId, success: true, role });
        }

        res.status(200).json({ success: true, message: 'Bulk role update completed', results });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// 8. Change Password (Authenticated)
export const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ success: false, message: "Please provide old and new password" });
    }
    const user = await User.findById(req.user._id).select("+password");
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    if (!(await bcrypt.compare(oldPassword, user.password))) {
      return res.status(400).json({ success: false, message: "Old password is incorrect" });
    }
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    await user.save();
    return res.status(200).json({ success: true, message: "Password changed successfully" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Server error during password change" });
  }
}

// Delete user account
export const deleteAccount = async (req, res) => {
  try {
    const { password } = req.body;
    
    if (!password) {
      return res.status(400).json({ success: false, message: "Password is required" });
    }

    const user = await User.findById(req.user._id).select("+password");
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Verify password before deletion
    if (!(await bcrypt.compare(password, user.password))) {
      return res.status(400).json({ success: false, message: "Password is incorrect" });
    }

    // Delete the user
    await User.findByIdAndDelete(req.user._id);

    // Clear the cookie
    res.cookie("token", "", {
      expires: new Date(Date.now()),
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
    });

    return res.status(200).json({ success: true, message: "Account deleted successfully" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Server error during account deletion" });
  }
}