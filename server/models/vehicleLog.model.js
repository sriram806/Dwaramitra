import mongoose from 'mongoose';

const vehicleLogSchema = new mongoose.Schema(
  {
    vehicleId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'UniversityVehicle',
      required: true,
    },
    vehicleNumber: {
      type: String,
      required: true,
      trim: true,
      uppercase: true,
    },
    action: {
      type: String,
      enum: ['entry', 'exit', 'updated', 'deleted'],
      required: true,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
    performedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    gateName: {
      type: String,
      required: true,
      trim: true,
    },
    details: {
      ownerName: String,
      vehicleType: String,
      department: String,
      purpose: String,
      notes: String,
    },
    location: {
      latitude: Number,
      longitude: Number,
    },
    ipAddress: {
      type: String,
    },
    deviceInfo: {
      userAgent: String,
      platform: String,
    },
  },
  { timestamps: true }
);

// Index for faster queries
vehicleLogSchema.index({ vehicleNumber: 1, timestamp: -1 });
vehicleLogSchema.index({ performedBy: 1, timestamp: -1 });
vehicleLogSchema.index({ action: 1, timestamp: -1 });

const VehicleLog = mongoose.model('VehicleLog', vehicleLogSchema);
export default VehicleLog;