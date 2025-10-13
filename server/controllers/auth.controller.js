import User from "../models/user.model.js";
import bcrypt from "bcryptjs";
import sendMail from "../config/nodemailer.js";
import { generateOTP } from "../services/otp.services.js";
import { createSendToken } from "../services/auth.services.js";

// 1. Registration
export const registration = async (req, res) => {
  let createdUser;

  try {
    const { name, email, password, gender } = req.body;

    if (!name || !email || !password || !gender) {
      return res.status(400).json({ success: false, message: "All fields are required." });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, message: "Email is already registered." });
    }

    const otp = generateOTP();
    const otpExpireAt = new Date(Date.now() + 10 * 60 * 1000);

    const hashedPassword = await bcrypt.hash(password, 10);

    createdUser = await User.create({ name, email, password: hashedPassword, gender, otp, otpExpireAt });

    try {
      await sendMail({
        email: createdUser.email,
        subject: "Activate Your Dwaramitra Account",
        template: "activation",
        data: { otp, name: createdUser.name, email: createdUser.email }
      });
    } catch (mailError) {
      console.error("Mail error:", mailError);
    }

    return createSendToken(createdUser, 201, res, "Registration successful and OTP sent to your email");
  } catch (error) {
    console.error('Registration error:', error);
    if (createdUser?._id) {
      try {
        await User.findByIdAndDelete(createdUser._id);
      } catch (cleanupErr) {
        console.error('Cleanup error:', cleanupErr);
      }
    }

    return res.status(500).json({ success: false, message: "Server error during registration.", error: error.message });
  }
};

// 2. Verify OTP
export const VerifyOTP = async (req, res) => {
  const { otp } = req.body;

  if (!otp) {
    return res.status(400).json({ success: false, message: "Please provide otp" });
  }

  const user = req.user;
  try {
    if (user.otp !== otp) {
      return res.status(400).json({ success: false, message: "Invalid otp" });
    }
    if (user.isAccountVerified) {
      return res.status(400).json({ success: false, message: "Account already verified" });
    }
    if (!user.otpExpireAt || user.otpExpireAt < Date.now()) {
      return res.status(400).json({ success: false, message: "Otp expired" });
    }

    user.isAccountVerified = true;
    user.otp = undefined;
    user.otpExpireAt = undefined;
    await user.save({ validateBeforeSave: false });

    return createSendToken(user, 200, res, "Account verified successfully");
  } catch (error) {
    return res.status(500).json({ success: false, message: "Server error during verification" });
  }
}

// 3. Resend OTP
export const ResendOTP = async (req, res) => {
  try {
    const authUser = req.user;
    if (!authUser) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const user = await User.findById(authUser._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (user.isAccountVerified) {
      return res.status(400).json({ success: false, message: "Account already verified" });
    }

    const newOtp = generateOTP();
    const otpExpireAt = new Date(Date.now() + 10 * 60 * 1000);

    user.otp = newOtp;
    user.otpExpireAt = otpExpireAt;
    await user.save({ validateBeforeSave: false });

    try {
      await sendMail({
        email: user.email,
        subject: "Verify Your Flyobo Account",
        template: "activation",
        data: { otp: newOtp, name: user.name, email: user.email }
      });
    } catch (mailError) {
      console.error("Mail error:", mailError);
    }

    return res.status(200).json({ success: true, message: "Otp resent successfully" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Server error during resend" });
  }
}

// 4. Login 
export const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: "Please provide email and password" });
  }

  try {
    const user = await User.findOne({ email }).select("+password");
    if (!user) {
      return res.status(401).json({ success: false, message: "Invalid User" });
    }

    if (!(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ success: false, message: "Invalid Password" });
    }

    user.password = undefined;
    createSendToken(user, 200, res, "Login successful");
  } catch (error) {
    return res.status(500).json({ success: false, message: "Error in login" });
  }
};

// 5. Logout
export const logout = async (req, res) => {
  try {
    res.cookie("access_token", "logout", {
      expires: new Date(Date.now() + 5 * 1000),
      httpOnly: true,
      secure: NODE_ENV === "production",
    });
    res.status(200).json({ success: true, message: "Logout successful" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Logout failed" });
  }
};

// 6. Forgot Password
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: "Please provide email" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const resetPasswordOtp = generateOTP();
    const otpExpireAt = new Date(Date.now() + 10 * 60 * 1000);

    user.resetPasswordOtp = resetPasswordOtp;
    user.resetPasswordOtpExpireAt = otpExpireAt;
    await user.save({ validateBeforeSave: false });

    try {
      await sendMail({
        email: user.email,
        subject: "Reset Your Flyobo Account Password",
        template: "reset-password",
        data: { otp: resetPasswordOtp, name: user.name, email: user.email }
      });
    } catch (mailError) {
      console.error("Mail error:", mailError);
    }

    return res.status(200).json({ success: true, message: "Reset OTP sent successfully" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Server error during password reset" });
  }
}

// 7. Reset Password
export const resetPassword = async (req, res) => {
  try {
    const { email, otp, password } = req.body;
    if (!otp || !password) {
      return res.status(400).json({ success: false, message: "Please provide otp and password" });
    }
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    if (user.resetPasswordOtp !== otp) {
      return res.status(400).json({ success: false, message: "Invalid otp" });
    }
    if (!user.resetPasswordOtpExpireAt || user.resetPasswordOtpExpireAt < Date.now()) {
      return res.status(400).json({ success: false, message: "Otp expired" });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;
    user.resetPasswordOtp = undefined;
    user.resetPasswordOtpExpireAt = undefined;
    await user.save({ validateBeforeSave: false });
    return res.status(200).json({ success: true, message: "Password reset successfully" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Server error during password reset" });
  }
}

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
