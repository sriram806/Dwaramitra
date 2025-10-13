import ErrorHandler from "../utils/ErrorHandler.js";
import catchAsyncErrors from "../middleware/catchAsyncErrors.js";
import VehicleLog from "../models/vehicleLog.model.js";
import Vehicle from "../models/vehicle.model.js";

// Create vehicle log entry
export const createVehicleLog = async (vehicleData, action, performedBy, gateName, req) => {
  try {
    const logData = {
      vehicleId: vehicleData._id,
      vehicleNumber: vehicleData.vehicleNumber,
      action,
      performedBy,
      gateName,
      details: {
        ownerName: vehicleData.ownerName,
        vehicleType: vehicleData.vehicleType,
        department: vehicleData.department,
        purpose: vehicleData.purpose,
        notes: vehicleData.notes,
      },
      ipAddress: req?.ip || req?.connection?.remoteAddress,
      deviceInfo: {
        userAgent: req?.get('User-Agent'),
        platform: req?.get('X-Platform') || 'web',
      },
    };

    const log = await VehicleLog.create(logData);
    return log;
  } catch (error) {
    console.error('Error creating vehicle log:', error);
  }
};

// Get vehicle logs with filters
const getVehicleLogs = catchAsyncErrors(async (req, res, next) => {
  try {
    const {
      vehicleNumber,
      action,
      gateName,
      startDate,
      endDate,
      page = 1,
      limit = 20,
    } = req.query;

    // Build query
    const query = {};

    if (vehicleNumber) {
      query.vehicleNumber = { $regex: vehicleNumber, $options: 'i' };
    }

    if (action) {
      query.action = action;
    }

    if (gateName) {
      query.gateName = { $regex: gateName, $options: 'i' };
    }

    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) {
        query.timestamp.$gte = new Date(startDate);
      }
      if (endDate) {
        query.timestamp.$lte = new Date(endDate);
      }
    }

    // Only admins and guards can see all logs
    if (req.user.role === 'user') {
      query.performedBy = req.user._id;
    }

    const logs = await VehicleLog.find(query)
      .populate('performedBy', 'name email role')
      .sort({ timestamp: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await VehicleLog.countDocuments(query);

    res.status(200).json({
      success: true,
      logs,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalLogs: total,
        hasNextPage: page < Math.ceil(total / limit),
        hasPrevPage: page > 1,
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get vehicle history by vehicle number
const getVehicleHistory = catchAsyncErrors(async (req, res, next) => {
  try {
    const { vehicleNumber } = req.params;

    const logs = await VehicleLog.find({
      vehicleNumber: vehicleNumber.toUpperCase(),
    })
      .populate('performedBy', 'name role')
      .sort({ timestamp: -1 });

    const vehicle = await Vehicle.findOne({
      vehicleNumber: vehicleNumber.toUpperCase(),
    });

    res.status(200).json({
      success: true,
      vehicleNumber: vehicleNumber.toUpperCase(),
      currentStatus: vehicle?.status || 'unknown',
      totalEntries: logs.filter(log => log.action === 'entry').length,
      totalExits: logs.filter(log => log.action === 'exit').length,
      logs,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get activity analytics
const getActivityAnalytics = catchAsyncErrors(async (req, res, next) => {
  try {
    const { days = 7 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    // Daily activity summary
    const dailyActivity = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: startDate },
          action: { $in: ['entry', 'exit'] },
        },
      },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } },
            action: '$action',
          },
          count: { $sum: 1 },
        },
      },
      {
        $group: {
          _id: '$_id.date',
          entries: {
            $sum: { $cond: [{ $eq: ['$_id.action', 'entry'] }, '$count', 0] },
          },
          exits: {
            $sum: { $cond: [{ $eq: ['$_id.action', 'exit'] }, '$count', 0] },
          },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Hourly distribution
    const hourlyDistribution = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: startDate },
          action: { $in: ['entry', 'exit'] },
        },
      },
      {
        $group: {
          _id: { $hour: '$timestamp' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Gate-wise activity
    const gateActivity = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: startDate },
          action: { $in: ['entry', 'exit'] },
        },
      },
      {
        $group: {
          _id: '$gateName',
          entries: {
            $sum: { $cond: [{ $eq: ['$action', 'entry'] }, 1, 0] },
          },
          exits: {
            $sum: { $cond: [{ $eq: ['$action', 'exit'] }, 1, 0] },
          },
          total: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
    ]);

    res.status(200).json({
      success: true,
      analytics: {
        period: `Last ${days} days`,
        dailyActivity,
        hourlyDistribution,
        gateActivity,
        summary: {
          totalActivities: await VehicleLog.countDocuments({
            timestamp: { $gte: startDate },
            action: { $in: ['entry', 'exit'] },
          }),
          uniqueVehicles: (await VehicleLog.distinct('vehicleNumber', {
            timestamp: { $gte: startDate },
          })).length,
        },
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

export {
  getVehicleLogs,
  getVehicleHistory,
  getActivityAnalytics,
};