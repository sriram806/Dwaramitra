import redisClient from "../database/redis.js";
import User from "../models/user.model.js";

export const getUserById = async (id, res) => {
    const userJson = await redisClient.get(id);

    if (userJson) {
        const user = JSON.parse(userJson);
        res.status(200).json({ success: true, user })
    }
};

export const getAllUsersServices = async () => {
    const users = await User.find().sort({ createdAt: -1 });
    return users;
};

export const updateUserRoleService = async( res, id, role)=>{
    const user = await User.findByIdAndUpdate(id, {role}, {new: true});

    res.status(201).json({
        success: true,
        user
    });
}