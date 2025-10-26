import mongoose from 'mongoose';

const vehicleSchema = new mongoose.Schema({
  vehicleNumber: {
    type: String,
    required: [true, 'Vehicle number is required'],
    uppercase: true,
    trim: true,
    index: true
  },
  vehicleType: {
    type: String,
    required: [true, 'Vehicle type is required'],
    enum: ['car', 'bike', 'bicycle', 'truck', 'bus', 'auto', 'scooter', 'other'],
    lowercase: true
  },
  ownerName: {
    type: String,
    required: [true, 'Owner name is required'],
    trim: true
  },
  ownerRole: {
    type: String,
    required: [true, 'Owner role is required'],
    enum: ['student', 'faculty', 'staff', 'visitor', 'contractor', 'other'],
    lowercase: true
  },
  universityId: {
    type: String,
    trim: true,
    sparse: true
  },
  department: {
    type: String,
    trim: true
  },
  contactNumber: {
    type: String,
    required: [true, 'Contact number is required'],
    trim: true
  },
  entryTime: {
    type: Date,
    required: true,
    default: Date.now
  },
  exitTime: {
    type: Date,
    default: null
  },
  gateName: {
    type: String,
    required: [true, 'Gate name is required'],
    enum: ['GATE 1', 'GATE 2'],
    trim: true
  },
  status: {
    type: String,
    enum: ['inside', 'exited'],
    default: 'inside'
  },
  duration: {
    type: Number, // in minutes
    default: 0
  },
  purpose: {
    type: String,
    trim: true
  },
  verifiedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  notes: {
    type: String,
    trim: true
  },
  ownerPhone: {
    type: String,
    trim: true
  },
  isBlacklisted: {
    type: Boolean,
    default: false
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
}, {
  timestamps: true
});

vehicleSchema.index({ vehicleNumber: 1, status: 1 });
vehicleSchema.index({ entryTime: -1 });
vehicleSchema.index({ status: 1 });
vehicleSchema.index({ vehicleType: 1 });
vehicleSchema.index({ ownerRole: 1 });
vehicleSchema.index({ gateName: 1 });

vehicleSchema.virtual('formattedDuration').get(function() {
  if (this.duration === 0) return '0 mins';
  
  const hours = Math.floor(this.duration / 60);
  const minutes = this.duration % 60;
  
  if (hours > 0) {
    return `${hours}h ${minutes}m`;
  } else {
    return `${minutes}m`;
  }
});

vehicleSchema.virtual('isInside').get(function() {
  return this.status === 'inside';
});

vehicleSchema.virtual('hasExited').get(function() {
  return this.status === 'exited';
});

vehicleSchema.set('toJSON', { virtuals: true });
vehicleSchema.set('toObject', { virtuals: true });

// Pre-save middleware to calculate duration if exit time is set
vehicleSchema.pre('save', function(next) {
  if (this.exitTime && this.entryTime) {
    this.duration = Math.floor((this.exitTime - this.entryTime) / (1000 * 60));
  }
  next();
});

export default mongoose.model('Vehicle', vehicleSchema);
