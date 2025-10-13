import User from '../models/user.model.js';

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
        const { name, email, phone, avatar } = req.body;
        const user = await User.findById(req.user._id);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });
        if (name) user.name = name;
        if (email) user.email = email;
        if (phone) user.phone = phone;
        if (avatar) user.avatar = avatar;
        await user.save();
        res.status(200).json({ success: true, message: "Successfully Updated", user });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// Add item to saved items
export const addSavedItem = async (req, res) => {
    try {
        const { itemId } = req.body;
        if (!itemId) return res.status(400).json({ success: false, message: 'Item ID is required' });

        const user = await User.findById(req.user._id);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });

        if (!user.savedItems.includes(itemId)) {
            user.savedItems.push(itemId);
            await user.save();
        }

        res.status(200).json({ success: true, message: 'Item added to saved items', savedItems: user.savedItems });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// Get user's saved items
export const getSavedItems = async (req, res) => {
    try {
        const user = await User.findById(req.user._id).populate('savedItems');
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });
        res.status(200).json({ success: true, message: 'Saved items retrieved successfully', savedItems: user.savedItems });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// Remove item from saved items
export const removeSavedItem = async (req, res) => {
    try {
        const { itemId } = req.params;
        const user = await User.findById(req.user._id);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });

        user.savedItems = user.savedItems.filter(
            (item) => item.toString() !== itemId
        );
        await user.save();
        res.status(200).json({ success: true, message: 'Item removed from saved items', savedItems: user.savedItems });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
};
