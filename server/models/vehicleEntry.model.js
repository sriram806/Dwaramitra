import mongoose from 'mongoose';

const vehicleEntrySchema = new mongoose.Schema(
  {
    // Vehicle Information
    vehicleNumber: {
      type: String,
      required: [true, 'Vehicle number is required'],
      uppercase: true,
      trim: true,
    },
    vehicleType: {
      type: String,
      enum: ['Car', 'Motorcycle', 'Truck', 'Bus', 'Van', 'Bicycle', 'Other'],
      required: [true, 'Vehicle type is required'],
    },
    vehicleModel: {
      type: String,
      trim: true,
    },
    vehicleColor: {
      type: String,
      trim: true,
    },
    
    // Driver/Owner Information
    driverName: {
      type: String,
      required: [true, 'Driver name is required'],
      trim: true,
    },
    driverPhone: {
      type: String,
      trim: true,
      match: [/^[0-9]{10}$/, 'Please enter a valid 10-digit phone number'],
    },
    driverIdType: {
      type: String,
      enum: ['Driving License', 'Aadhar Card', 'PAN Card', 'Employee ID', 'Student ID', 'Other'],
    },
    driverIdNumber: {
      type: String,
      trim: true,
    },
    
    // Entry/Exit Information
    entryTime: {
      type: Date,
      required: [true, 'Entry time is required'],
      default: Date.now,
    },
    exitTime: {
      type: Date,
      default: null,
    },
    status: {
      type: String,
      enum: ['Inside', 'Exited'],
      default: 'Inside',
    },
    
    // Guard/Security Officer Information
    loggedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Logged by user is required'],
    },
    loggedByName: {
      type: String,
      required: [true, 'Logged by name is required'],
    },
    loggedByRole: {
      type: String,
      enum: ['guard', 'security officer'],
      required: [true, 'Logged by role is required'],
    },
    shift: {
      type: String,
      enum: ['Day Shift', 'Night Shift'],
    },
    
    // Purpose and Additional Information
    visitPurpose: {
      type: String,
      enum: ['Official Visit', 'Delivery', 'Maintenance', 'Guest Visit', 'Employee/Student', 'Emergency', 'Other'],
      required: [true, 'Visit purpose is required'],
    },
    destinationDepartment: {
      type: String,
      trim: true,
    },
    contactPersonName: {
      type: String,
      trim: true,
    },
    contactPersonPhone: {
      type: String,
      trim: true,
    },
    
    // Additional Information
    remarks: {
      type: String,
      trim: true,
      maxlength: [500, 'Remarks cannot exceed 500 characters'],
    },
    vehiclePhotos: [{
      public_id: String,
      url: String,
    }],
    
    // Tracking Information
    isActive: {
      type: Boolean,
      default: true,
    },
    lastUpdatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  { 
    timestamps: true,
  }
);

// Add indexes for better query performance
vehicleEntrySchema.index({ vehicleNumber: 1, status: 1 });
vehicleEntrySchema.index({ loggedBy: 1, createdAt: -1 });
vehicleEntrySchema.index({ createdAt: -1, status: 1 });

// Static method to find active entry for a vehicle
vehicleEntrySchema.statics.findActiveEntry = function(vehicleNumber) {
  return this.findOne({
    vehicleNumber: vehicleNumber.toUpperCase(),
    status: 'Inside',
    isActive: true
  });
};

const VehicleEntry = mongoose.model('VehicleEntry', vehicleEntrySchema);
export default VehicleEntry;