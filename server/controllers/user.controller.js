import User from '../models/user.model.js';
import bcrypt from 'bcryptjs';
import { io } from '../app.js';
import VehicleLog from '../models/vehicleLog.model.js';

export const getAllUsers = async (req, res) => {
    try {
        if (!req.user || !['admin', 'security officer'].includes(req.user.role)) {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }
        
        const { page = 1, limit = 10, search = '', role = '', designation = '' } = req.query;
        
        // Build filter object
        const filter = {};
        
        // If security officer, only show guards and users (not other security officers or admins)
        if (req.user.role === 'security officer') {
            filter.role = { $in: ['user', 'guard'] };
        }
        
        if (search) {
            filter.$or = [
                { name: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } },
                { universityId: { $regex: search, $options: 'i' } }
            ];
        }
        if (role && (req.user.role === 'admin' || ['user', 'guard'].includes(role))) {
            filter.role = role;
        }
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

// Get user profile (optimized for performance)
export const getProfile = async (req, res) => {
    try {
        // Use lean() for better performance since we don't need mongoose document methods
        const user = await User.findById(req.user._id)
            .select('-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt')
            .lean();
            
        if (!user) {
            return res.status(404).json({ 
                success: false, 
                message: 'User not found' 
            });
        }
        
        return res.status(200).json({ 
            success: true, 
            user 
        });
    } catch (error) {
        console.error('Profile fetch error:', error);
        return res.status(500).json({ 
            success: false, 
            message: 'Server error', 
            error: error.message 
        });
    }
};

// Update user profile (optimized)
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
        
        // Build update object with only provided fields
        const updateFields = {};
        if (name) updateFields.name = name;
        if (email) updateFields.email = email;
        if (phone) updateFields.phone = phone;
        if (gender && ['Male', 'Female'].includes(gender)) updateFields.gender = gender;
        if (universityId) updateFields.universityId = universityId;
        if (department) updateFields.department = department;
        if (designation && ['Student', 'Staff', 'Faculty', 'Admin Staff', 'Visitor'].includes(designation)) {
            updateFields.designation = designation;
        }
        if (avatar) updateFields.avatar = avatar;
        
        // Add updatedAt timestamp
        updateFields.updatedAt = new Date();
        
        // Use findByIdAndUpdate for better performance
        const updatedUser = await User.findByIdAndUpdate(
            req.user._id,
            updateFields,
            { 
                new: true, 
                runValidators: true,
                select: '-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt'
            }
        ).lean();
        
        if (!updatedUser) {
            return res.status(404).json({ 
                success: false, 
                message: 'User not found' 
            });
        }
        
        res.status(200).json({ 
            success: true, 
            message: "Successfully Updated", 
            user: updatedUser 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Update user designation (for admin/authorized users)
export const updateUserDesignation = async (req, res) => {
    try {
        const { userId } = req.params;
        const { designation } = req.body;
        
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
        const { role, shift, assignedGates } = req.body;
        const { id } = req.params;

        if (!['admin', 'officer', 'guard', 'user'].includes(role)) {
            return res.status(400).json({ success: false, message: 'Invalid role' });
        }

        const user = await User.findById(id);
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        // Prevent changing admin role unless it's another admin
        if (user.role === 'admin' && req.user.role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Only admin can change admin roles' });
        }

        // Update role and security-specific fields
        user.role = role;
        
        // Update security-specific fields if role is guard or officer
        if (['guard', 'officer'].includes(role)) {
            if (shift) user.shift = shift;
            if (assignedGates) user.assignedGates = assignedGates;
            
            // Generate guard ID if not exists
            if (!user.guardId) {
                const lastGuard = await User.findOne({ role: { $in: ['guard', 'officer'] } })
                    .sort('-guardId')
                    .select('guardId');
                
                const lastId = lastGuard ? parseInt(lastGuard.guardId?.substring(1) || '0') : 0;
                user.guardId = `G${String(lastId + 1).padStart(4, '0')}`;
            }
        }

        await user.save();
        
        // Emit user update event
        if (io) {
            io.emit('user:update', {
                type: 'USER_UPDATED',
                data: user
            });
        }

        res.status(200).json({ 
            success: true, 
            message: 'User role updated successfully', 
            user: {
                _id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                guardId: user.guardId,
                shift: user.shift,
                assignedGates: user.assignedGates,
                isOnDuty: user.isOnDuty
            } 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Guard check-in
export const guardCheckIn = async (req, res) => {
    try {
        const { gate } = req.body;
        const userId = req.user._id;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        if (!['guard', 'officer'].includes(user.role)) {
            return res.status(403).json({ success: false, message: 'Only security personnel can check in' });
        }

        if (user.assignedGates && !user.assignedGates.includes(gate)) {
            return res.status(400).json({ 
                success: false, 
                message: `You are not assigned to ${gate} gate` 
            });
        }

        // Check if already on duty
        if (user.isOnDuty) {
            return res.status(400).json({ 
                success: false, 
                message: 'You are already on duty' 
            });
        }

        user.isOnDuty = true;
        user.lastCheckIn = new Date();
        await user.save();

        // Emit guard check-in event
        if (io) {
            io.emit('guard:checkin', {
                type: 'GUARD_CHECKED_IN',
                data: {
                    userId: user._id,
                    name: user.name,
                    guardId: user.guardId,
                    gate,
                    time: user.lastCheckIn
                }
            });
        }

        res.status(200).json({ 
            success: true, 
            message: 'Checked in successfully',
            data: {
                isOnDuty: user.isOnDuty,
                lastCheckIn: user.lastCheckIn,
                gate
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Guard check-out
export const guardCheckOut = async (req, res) => {
    try {
        const userId = req.user._id;
        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        if (!user.isOnDuty) {
            return res.status(400).json({ 
                success: false, 
                message: 'You are not currently on duty' 
            });
        }

        // Get all vehicles logged by this guard that are still parked
        const parkedVehicles = await VehicleLog.find({ 
            'entryGuard.id': user._id,
            status: 'parked'
        });

        if (parkedVehicles.length > 0) {
            return res.status(400).json({ 
                success: false, 
                message: `Cannot check out with ${parkedVehicles.length} vehicles still parked`,
                parkedVehiclesCount: parkedVehicles.length
            });
        }

        user.isOnDuty = false;
        user.lastCheckOut = new Date();
        await user.save();

        // Emit guard check-out event
        if (io) {
            io.emit('guard:checkout', {
                type: 'GUARD_CHECKED_OUT',
                data: {
                    userId: user._id,
                    name: user.name,
                    guardId: user.guardId,
                    time: user.lastCheckOut,
                    duration: user.lastCheckOut - user.lastCheckIn
                }
            });
        }

        res.status(200).json({ 
            success: true, 
            message: 'Checked out successfully',
            data: {
                isOnDuty: user.isOnDuty,
                lastCheckOut: user.lastCheckOut,
                duration: user.lastCheckOut - user.lastCheckIn
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Get all guards on duty
export const getGuardsOnDuty = async (req, res) => {
    try {
        const guards = await User.find({ 
            role: { $in: ['guard', 'officer'] },
            isOnDuty: true 
        }).select('name email guardId shift assignedGates lastCheckIn');

        res.status(200).json({ 
            success: true, 
            count: guards.length,
            data: guards 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Get guard activity log
export const getGuardActivity = async (req, res) => {
    try {
        const { guardId, startDate, endDate } = req.query;
        const query = { 'entryGuard.id': guardId };

        if (startDate || endDate) {
            query.entryTime = {};
            if (startDate) query.entryTime.$gte = new Date(startDate);
            if (endDate) query.entryTime.$lte = new Date(endDate);
        }

        const logs = await VehicleLog.find(query)
            .sort({ entryTime: -1 })
            .populate('vehicle', 'vehicleNumber ownerName')
            .select('vehicleNumber entryTime exitTime status entryGate exitGate');

        res.status(200).json({ 
            success: true, 
            count: logs.length,
            data: logs 
        });
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

// Admin/Security Officer: Assign shift and gate to user
export const assignShiftAndGate = async (req, res) => {
    try {
        const { userId } = req.params;
        const { shift, assignedGates } = req.body;
        
        // Check if user has admin or security officer permission
        if (!req.user || !['admin', 'security officer'].includes(req.user.role)) {
            return res.status(403).json({ success: false, message: 'Only admin or security officer can assign shift and gate' });
        }
        
        if (!userId) {
            return res.status(400).json({ success: false, message: 'User ID is required' });
        }
        
        const targetUser = await User.findById(userId);
        if (!targetUser) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        
        // Security officers can only manage guards and users, not other security officers or admins
        if (req.user.role === 'security officer' && 
            !['user', 'guard'].includes(targetUser.role)) {
            return res.status(403).json({ 
                success: false, 
                message: 'Security officers can only manage guards and users' 
            });
        }
        
        // Validate shift
        const validShifts = ['Day Shift', 'Night Shift'];
        if (shift && !validShifts.includes(shift)) {
            return res.status(400).json({ success: false, message: 'Invalid shift' });
        }
        
        // Validate gates
        const validGates = ['GATE 1', 'GATE 2'];
        if (assignedGates && Array.isArray(assignedGates)) {
            const invalidGates = assignedGates.filter(gate => !validGates.includes(gate));
            if (invalidGates.length > 0) {
                return res.status(400).json({ success: false, message: 'Invalid gates. Must be GATE 1 or GATE 2' });
            }
        }
        
        // Update fields if provided
        const updateFields = {};
        if (shift) updateFields.shift = shift;
        if (assignedGates) updateFields.assignedGates = assignedGates;
        updateFields.updatedAt = new Date();
        
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            updateFields,
            { 
                new: true, 
                runValidators: true,
                select: '-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt'
            }
        ).lean();
        
        res.status(200).json({ 
            success: true, 
            message: 'Shift and gate assigned successfully', 
            user: updatedUser 
        });
    } catch (error) {
        console.error('Assign shift and gate error:', error);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
}

// Security Officer: Get all guards under their supervision
export const getGuardsUnderSupervision = async (req, res) => {
    try {
        // Check if user has security officer permission
        if (!req.user || req.user.role !== 'security officer') {
            return res.status(403).json({ success: false, message: 'Only security officers can view guards' });
        }
        
        const { page = 1, limit = 10, shift = '', gate = '', status = '' } = req.query;
        
        // Build filter object for guards
        const filter = { role: 'guard' };
        if (shift) filter.shift = shift;
        if (gate) filter.assignedGates = { $in: [gate] };
        if (status === 'on-duty') filter.isOnDuty = true;
        if (status === 'off-duty') filter.isOnDuty = false;
        
        const guards = await User.find(filter)
            .select('-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt')
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .sort({ createdAt: -1 });
        
        const total = await User.countDocuments(filter);
        
        res.status(200).json({ 
            success: true, 
            guards, 
            totalPages: Math.ceil(total / limit),
            currentPage: page,
            total 
        });
    } catch (error) {
        console.error('Get guards error:', error);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
}

// Security Officer: Update guard details
export const updateGuardDetails = async (req, res) => {
    try {
        const { guardId } = req.params;
        const { shift, assignedGates, isOnDuty } = req.body;
        
        // Check if user has security officer permission
        if (!req.user || req.user.role !== 'security officer') {
            return res.status(403).json({ success: false, message: 'Only security officers can update guard details' });
        }
        
        if (!guardId) {
            return res.status(400).json({ success: false, message: 'Guard ID is required' });
        }
        
        // Find the guard
        const guard = await User.findById(guardId);
        if (!guard || guard.role !== 'guard') {
            return res.status(404).json({ success: false, message: 'Guard not found' });
        }
        
        // Validate shift
        const validShifts = ['Day Shift', 'Night Shift'];
        if (shift && !validShifts.includes(shift)) {
            return res.status(400).json({ success: false, message: 'Invalid shift. Only Day Shift and Night Shift are allowed' });
        }
        
        // Validate gates
        const validGates = ['GATE 1', 'GATE 2'];
        if (assignedGates && Array.isArray(assignedGates)) {
            const invalidGates = assignedGates.filter(gate => !validGates.includes(gate));
            if (invalidGates.length > 0) {
                return res.status(400).json({ success: false, message: 'Invalid gates. Must be GATE 1 or GATE 2' });
            }
        }
        
        // Update fields if provided
        const updateFields = {};
        if (shift) updateFields.shift = shift;
        if (assignedGates) updateFields.assignedGates = assignedGates;
        if (typeof isOnDuty === 'boolean') updateFields.isOnDuty = isOnDuty;
        updateFields.updatedAt = new Date();
        
        const updatedGuard = await User.findByIdAndUpdate(
            guardId,
            updateFields,
            { 
                new: true, 
                runValidators: true,
                select: '-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt'
            }
        ).lean();
        
        res.status(200).json({ 
            success: true, 
            message: 'Guard details updated successfully', 
            guard: updatedGuard 
        });
    } catch (error) {
        console.error('Update guard details error:', error);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
}

// Security Officer: Get guard activity report
export const getGuardActivityReport = async (req, res) => {
    try {
        // Check if user has security officer permission
        if (!req.user || req.user.role !== 'security officer') {
            return res.status(403).json({ success: false, message: 'Only security officers can view guard activity reports' });
        }
        
        const { guardId, startDate, endDate, page = 1, limit = 10 } = req.query;
        
        let filter = { role: 'guard' };
        if (guardId) filter._id = guardId;
        
        const guards = await User.find(filter)
            .select('name guardId shift assignedGates isOnDuty lastCheckIn lastCheckOut')
            .sort({ name: 1 });
        
        // Add check-in/check-out activity if needed
        const guardsWithActivity = guards.map(guard => ({
            ...guard.toObject(),
            totalHoursWorked: guard.lastCheckIn && guard.lastCheckOut 
                ? Math.round((guard.lastCheckOut - guard.lastCheckIn) / (1000 * 60 * 60) * 100) / 100
                : 0,
            status: guard.isOnDuty ? 'On Duty' : 'Off Duty'
        }));
        
        res.status(200).json({ 
            success: true, 
            guards: guardsWithActivity,
            total: guardsWithActivity.length
        });
    } catch (error) {
        console.error('Get guard activity report error:', error);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
}

// Get all guards (for admin and security officers)
export const getAllGuards = async (req, res) => {
    try {
        // Check permissions
        if (!req.user || !['admin', 'security officer'].includes(req.user.role)) {
            return res.status(403).json({ success: false, message: 'Access denied' });
        }
        
        const { page = 1, limit = 10, shift = '', gate = '', status = '' } = req.query;
        
        // Build filter for guards only
        const filter = { role: 'guard' };
        if (shift && shift !== 'all') filter.shift = shift;
        if (gate && gate !== 'all') filter.assignedGates = { $in: [gate] };
        if (status === 'on-duty') filter.isOnDuty = true;
        if (status === 'off-duty') filter.isOnDuty = false;
        
        const guards = await User.find(filter)
            .select('-password -otp -otpExpireAt -resetPasswordOtp -resetPasswordOtpExpireAt')
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .sort({ name: 1 });
        
        const total = await User.countDocuments(filter);
        
        res.status(200).json({ 
            success: true, 
            guards, 
            pagination: {
                totalPages: Math.ceil(total / limit),
                currentPage: parseInt(page),
                total,
                hasNext: page * limit < total,
                hasPrev: page > 1
            }
        });
    } catch (error) {
        console.error('Get all guards error:', error);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
}