import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [3, 'Name must be at least 3 characters long'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email'],
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      select: false,
      minlength: [6, 'Password must be at least 6 characters long'],
    },
    gender: {
      type: String,
      enum: ['Male', 'Female']
    },
    phone: {
      type: String,
      trim: true,
      match: [/^[0-9]{10}$/, 'Please enter a valid 10-digit phone number'],
    },
    universityId: {
      type: String,
      uppercase: true,
      trim: true,
    },
    department: {
      type: String,
      trim: true,
    },
    designation: {
      type: String,
      enum: ['Student', 'Staff', 'Faculty', 'Admin Staff', 'Visitor'],
      default: 'Student',
    },
    role: {
      type: String,
      enum: ['user', 'guard', 'security officer', 'admin'],
      default: 'user',
    },
    shift: {
      type: String,
      enum: ['Day Shift', 'Night Shift'],
      default: null,
      validate: {
        validator: function(value) {
          if (!value) return true;
          return this.role === 'guard';
        },
        message: 'Shift can only be assigned to guards'
      }
    },
    isAccountVerified: {
      type: Boolean,
      default: false,
    },
    otp: {
      type: String,
      default: null,
    },
    otpExpireAt: {
      type: Date,
      default: null,
    },
    resetPasswordOtp: {
      type: String,
      default: null,
    },
    resetPasswordOtpExpireAt: {
      type: Date,
      default: null,
    },
    avatar: {
      public_id: String,
      url: String,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

// Create a sparse unique index for universityId to allow multiple null values
userSchema.index({ universityId: 1 }, { unique: true, sparse: true });

const User = mongoose.model('User', userSchema);
export default User;
