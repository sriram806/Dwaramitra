import mongoose from 'mongoose';

const auditTrailSchema = new mongoose.Schema({
  action: {
    type: String,
    required: true,
    enum: ['CREATE', 'READ', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'AUTH_FAILURE', 'SYSTEM_EVENT']
  },
  entity: {
    type: String,
    required: true,
    enum: ['USER', 'VEHICLE', 'LOG', 'GUARD', 'GATE', 'SHIFT', 'REPORT', 'SYSTEM']
  },
  entityId: {
    type: mongoose.Schema.Types.ObjectId,
    index: true
  },
  performedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  ipAddress: String,
  userAgent: String,
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed
  },
  status: {
    type: String,
    enum: ['SUCCESS', 'FAILURE', 'WARNING'],
    default: 'SUCCESS'
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for faster querying
auditTrailSchema.index({ entity: 1, entityId: 1 });
auditTrailSchema.index({ performedBy: 1 });
auditTrailSchema.index({ timestamp: -1 });

// Virtual for human-readable timestamp
auditTrailSchema.virtual('timeAgo').get(function() {
  return this.timestamp.toLocaleString();
});

// Static method to log an action
auditTrailSchema.statics.log = async function(data) {
  try {
    const audit = new this({
      action: data.action,
      entity: data.entity,
      entityId: data.entityId,
      performedBy: data.userId,
      ipAddress: data.ipAddress,
      userAgent: data.userAgent,
      metadata: data.metadata || {},
      status: data.status || 'SUCCESS',
      timestamp: data.timestamp || new Date()
    });
    await audit.save();
    return audit;
  } catch (error) {
    console.error('Audit log error:', error);
    throw error;
  }
};

const AuditTrail = mongoose.model('AuditTrail', auditTrailSchema);

export default AuditTrail;
