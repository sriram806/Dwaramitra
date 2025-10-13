import mongoose from "mongoose";

const VehicleSchema = new mongoose.Schema(
  {
    vehicleNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      uppercase: true,
    },
    vehicleType: {
      type: String,
      required: true,
      enum: ["two-wheeler", "four-wheeler", "three-wheeler", "bicycle", "other"],
    },
    ownerName: {
      type: String,
      required: true,
      trim: true,
    },
    ownerRole: {
      type: String,
      required: true,
      enum: ["student", "faculty", "staff", "visitor"],
      default: "student",
    },
    universityId: {
      type: String,
      required: function () {
        return this.ownerRole !== "visitor";
      },
      trim: true,
    },
    department: {
      type: String,
      trim: true,
      required: function () {
        return this.ownerRole !== "visitor";
      },
    },
    contactNumber: {
      type: String,
      required: true,
      trim: true,
    },
    entryTime: {
      type: Date,
      default: Date.now,
    },
    exitTime: {
      type: Date,
      default: null,
    },
    gateName: {
      type: String,
      required: true,
      trim: true,
    },
    status: {
      type: String,
      enum: ["inside", "exited"],
      default: "inside",
    },
    duration: {
      type: Number,
      default: 0,
    },
    purpose: {
      type: String,
      trim: true,
    },
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Guard",
    },
    notes: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// Auto-calculate duration when exitTime is set
VehicleSchema.pre("save", function (next) {
  if (this.exitTime && this.entryTime) {
    this.duration = Math.floor((this.exitTime - this.entryTime) / (1000 * 60)); // minutes
  }
  next();
});

// Virtual to display formatted duration
VehicleSchema.virtual("formattedDuration").get(function () {
  if (this.duration === 0) return "0 mins";

  const hours = Math.floor(this.duration / 60);
  const minutes = this.duration % 60;

  if (hours > 0) {
    return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
  }
  return `${minutes}m`;
});

// Virtual for live duration (if still inside campus)
VehicleSchema.virtual("currentDuration").get(function () {
  if (this.status === "exited") return this.formattedDuration;

  const now = new Date();
  const durationMs = now - this.entryTime;
  const currentMinutes = Math.floor(durationMs / (1000 * 60));

  const hours = Math.floor(currentMinutes / 60);
  const minutes = currentMinutes % 60;

  if (hours > 0) {
    return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
  }
  return `${minutes}m`;
});

export default mongoose.model("UniversityVehicle", VehicleSchema);
