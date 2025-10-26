import mongoose from 'mongoose';

const vehicleLogSchema = new mongoose.Schema({
  vehicle: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicle',
    required: true
  },
  vehicleNumber: {
    type: String,
    required: true,
    trim: true,
    uppercase: true
  },
  vehicleType: {
    type: String,
    enum: ['car', 'bike', 'bicycle', 'truck', 'bus', 'auto', 'scooter', 'other'],
    lowercase: true
  },
  ownerName: {
    type: String,
    trim: true
  },
  ownerType: {
    type: String,
    enum: ['faculty', 'staff', 'student', 'visitor', 'service', 'other'],
    required: true
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
    trim: true
  },

  // Entry/Exit Information
  entryTime: {
    type: Date,
    default: Date.now
  },
  exitTime: {
    type: Date
  },
  
  // Guard Information
  entryBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  entryGuard: {
    id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    name: {
      type: String,
      required: true
    }
  },
  exitGuard: {
    id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    name: String
  },
  
  // Gate Information
  entryGate: {
    type: String,
    enum: ['GATE 1', 'GATE 2'],
    required: true
  },
  exitGate: {
    type: String,
    enum: ['GATE 1', 'GATE 2']
  },
  
  // Shift Information
  entryShift: {
    type: String,
    enum: ['Day Shift', 'Night Shift'],
    required: true
  },
  
  purpose: {
    type: String,
    trim: true,
    required: function() {
      return this.ownerType !== 'faculty';
    }
  },
  status: {
    type: String,
    enum: ['parked', 'exited'],
    default: 'parked'
  },
  isPreRegistered: {
    type: Boolean,
    default: false
  },
  expectedExitTime: {
    type: Date
  },
  notes: {
    type: String,
    trim: true
  },
  
  // Security Flags
  isSuspicious: {
    type: Boolean,
    default: false
  },
  securityCheck: {
    performed: Boolean,
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    notes: String
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

vehicleLogSchema.index({ vehicle: 1, status: 1 });
vehicleLogSchema.index({ vehicleNumber: 1, status: 1 });
vehicleLogSchema.index({ entryGate: 1, status: 1 });
vehicleLogSchema.index({ entryTime: -1 });
vehicleLogSchema.index({ 'entryGuard.id': 1, status: 1 });
vehicleLogSchema.index({ ownerType: 1, status: 1 });

vehicleLogSchema.virtual('duration').get(function() {
  if (this.exitTime && this.entryTime) {
    return this.exitTime - this.entryTime;
  }
  return null;
});

vehicleLogSchema.pre('save', function(next) {
  if (this.isModified('exitTime') && this.exitTime) {
    if (this.exitTime < this.entryTime) {
      throw new Error('Exit time cannot be before entry time');
    }
  }
  next();
});

export default mongoose.model('VehicleLog', vehicleLogSchema);
