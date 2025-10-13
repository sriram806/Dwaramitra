import ErrorHandler from "../utils/ErrorHandler.js";
import catchAsyncErrors from "../middleware/catchAsyncErrors.js";
import Vehicle from "../models/vehicle.model.js";

// Add new vehicle
const addVehicle = catchAsyncErrors(async (req, res, next) => {
  try {
    const {
      vehicleNumber,
      vehicleType,
      ownerName,
      ownerPhone,
      parkingSlot,
      parkingFee,
      notes,
    } = req.body;

    // Check if vehicle already exists and is currently parked
    const existingVehicle = await Vehicle.findOne({
      vehicleNumber: vehicleNumber.toUpperCase(),
      status: "parked",
    });

    if (existingVehicle) {
      return next(
        new ErrorHandler("Vehicle is already parked in the system", 400)
      );
    }

    // Check if parking slot is already occupied
    const slotOccupied = await Vehicle.findOne({
      parkingSlot,
      status: "parked",
    });

    if (slotOccupied) {
      return next(new ErrorHandler("Parking slot is already occupied", 400));
    }

    const vehicle = await Vehicle.create({
      vehicleNumber: vehicleNumber.toUpperCase(),
      vehicleType,
      ownerName,
      ownerPhone,
      parkingSlot,
      parkingFee: parkingFee || 0,
      notes,
      userId: req.user._id,
    });

    res.status(201).json({
      success: true,
      message: "Vehicle added successfully",
      vehicle,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get all vehicles for the authenticated user
const getAllVehicles = catchAsyncErrors(async (req, res, next) => {
  try {
    const { status, vehicleType, search, page = 1, limit = 10 } = req.query;

    // Build query
    const query = { userId: req.user._id };

    if (status) {
      query.status = status;
    }

    if (vehicleType) {
      query.vehicleType = vehicleType;
    }

    if (search) {
      query.$or = [
        { vehicleNumber: { $regex: search, $options: "i" } },
        { ownerName: { $regex: search, $options: "i" } },
        { ownerPhone: { $regex: search, $options: "i" } },
        { parkingSlot: { $regex: search, $options: "i" } },
      ];
    }

    const vehicles = await Vehicle.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Vehicle.countDocuments(query);

    res.status(200).json({
      success: true,
      vehicles,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(total / limit),
        totalVehicles: total,
        hasNextPage: page < Math.ceil(total / limit),
        hasPrevPage: page > 1,
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get vehicle by ID
const getVehicleById = catchAsyncErrors(async (req, res, next) => {
  try {
    const vehicle = await Vehicle.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!vehicle) {
      return next(new ErrorHandler("Vehicle not found", 404));
    }

    res.status(200).json({
      success: true,
      vehicle,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Update vehicle
const updateVehicle = catchAsyncErrors(async (req, res, next) => {
  try {
    const vehicle = await Vehicle.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!vehicle) {
      return next(new ErrorHandler("Vehicle not found", 404));
    }

    const {
      vehicleNumber,
      vehicleType,
      ownerName,
      ownerPhone,
      parkingSlot,
      parkingFee,
      notes,
    } = req.body;

    // Check if new vehicle number conflicts with existing vehicle
    if (vehicleNumber && vehicleNumber !== vehicle.vehicleNumber) {
      const existingVehicle = await Vehicle.findOne({
        vehicleNumber: vehicleNumber.toUpperCase(),
        status: "parked",
        _id: { $ne: req.params.id },
      });

      if (existingVehicle) {
        return next(
          new ErrorHandler("Vehicle number already exists for a parked vehicle", 400)
        );
      }
    }

    // Check if new parking slot is available
    if (parkingSlot && parkingSlot !== vehicle.parkingSlot) {
      const slotOccupied = await Vehicle.findOne({
        parkingSlot,
        status: "parked",
        _id: { $ne: req.params.id },
      });

      if (slotOccupied) {
        return next(new ErrorHandler("Parking slot is already occupied", 400));
      }
    }

    const updatedVehicle = await Vehicle.findByIdAndUpdate(
      req.params.id,
      {
        vehicleNumber: vehicleNumber?.toUpperCase() || vehicle.vehicleNumber,
        vehicleType: vehicleType || vehicle.vehicleType,
        ownerName: ownerName || vehicle.ownerName,
        ownerPhone: ownerPhone || vehicle.ownerPhone,
        parkingSlot: parkingSlot || vehicle.parkingSlot,
        parkingFee: parkingFee !== undefined ? parkingFee : vehicle.parkingFee,
        notes: notes !== undefined ? notes : vehicle.notes,
      },
      { new: true, runValidators: true }
    );

    res.status(200).json({
      success: true,
      message: "Vehicle updated successfully",
      vehicle: updatedVehicle,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Exit vehicle
const exitVehicle = catchAsyncErrors(async (req, res, next) => {
  try {
    const vehicle = await Vehicle.findOne({
      _id: req.params.id,
      userId: req.user._id,
      status: "parked",
    });

    if (!vehicle) {
      return next(new ErrorHandler("Parked vehicle not found", 404));
    }

    const exitTime = new Date();
    const duration = Math.floor((exitTime - vehicle.entryTime) / (1000 * 60)); // in minutes

    const updatedVehicle = await Vehicle.findByIdAndUpdate(
      req.params.id,
      {
        exitTime,
        duration,
        status: "exited",
      },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: "Vehicle exited successfully",
      vehicle: updatedVehicle,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Delete vehicle
const deleteVehicle = catchAsyncErrors(async (req, res, next) => {
  try {
    const vehicle = await Vehicle.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!vehicle) {
      return next(new ErrorHandler("Vehicle not found", 404));
    }

    await Vehicle.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: "Vehicle deleted successfully",
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get vehicle statistics
const getVehicleStats = catchAsyncErrors(async (req, res, next) => {
  try {
    const userId = req.user._id;

    // Get total counts
    const totalVehicles = await Vehicle.countDocuments({ userId });
    const parkedVehicles = await Vehicle.countDocuments({ userId, status: "parked" });
    const exitedVehicles = await Vehicle.countDocuments({ userId, status: "exited" });

    // Get today's stats
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todayEntries = await Vehicle.countDocuments({
      userId,
      entryTime: { $gte: today, $lt: tomorrow },
    });

    const todayExits = await Vehicle.countDocuments({
      userId,
      exitTime: { $gte: today, $lt: tomorrow },
    });

    // Calculate total revenue
    const revenueResult = await Vehicle.aggregate([
      { $match: { userId, status: "exited" } },
      { $group: { _id: null, totalRevenue: { $sum: "$parkingFee" } } },
    ]);

    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].totalRevenue : 0;

    // Get vehicle type distribution
    const typeDistribution = await Vehicle.aggregate([
      { $match: { userId } },
      { $group: { _id: "$vehicleType", count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);

    // Get monthly stats for the current year
    const currentYear = new Date().getFullYear();
    const monthlyStats = await Vehicle.aggregate([
      {
        $match: {
          userId,
          entryTime: {
            $gte: new Date(currentYear, 0, 1),
            $lt: new Date(currentYear + 1, 0, 1),
          },
        },
      },
      {
        $group: {
          _id: { $month: "$entryTime" },
          entries: { $sum: 1 },
          revenue: { $sum: "$parkingFee" },
        },
      },
      { $sort: { "_id": 1 } },
    ]);

    // Fill missing months with 0
    const monthlyStatsComplete = Array.from({ length: 12 }, (_, i) => {
      const month = i + 1;
      const existing = monthlyStats.find(stat => stat._id === month);
      return {
        month,
        entries: existing ? existing.entries : 0,
        revenue: existing ? existing.revenue : 0,
      };
    });

    res.status(200).json({
      success: true,
      stats: {
        overview: {
          totalVehicles,
          parkedVehicles,
          exitedVehicles,
          totalRevenue,
        },
        today: {
          entries: todayEntries,
          exits: todayExits,
        },
        typeDistribution,
        monthlyStats: monthlyStatsComplete,
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get recent activities
const getRecentActivities = catchAsyncErrors(async (req, res, next) => {
  try {
    const { limit = 10 } = req.query;

    const recentEntries = await Vehicle.find({
      userId: req.user._id,
    })
      .sort({ entryTime: -1 })
      .limit(parseInt(limit))
      .select("vehicleNumber vehicleType ownerName entryTime exitTime status parkingSlot");

    const activities = recentEntries.map(vehicle => ({
      id: vehicle._id,
      type: vehicle.status === "parked" ? "entry" : "exit",
      vehicleNumber: vehicle.vehicleNumber,
      vehicleType: vehicle.vehicleType,
      ownerName: vehicle.ownerName,
      timestamp: vehicle.status === "parked" ? vehicle.entryTime : vehicle.exitTime,
      parkingSlot: vehicle.parkingSlot,
    }));

    res.status(200).json({
      success: true,
      activities,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

export {
  addVehicle,
  getAllVehicles,
  getVehicleById,
  updateVehicle,
  exitVehicle,
  deleteVehicle,
  getVehicleStats,
  getRecentActivities,
};