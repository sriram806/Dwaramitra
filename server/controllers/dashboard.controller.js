import ErrorHandler from "../utils/ErrorHandler.js";
import catchAsyncErrors from "../middleware/catchAsyncErrors.js";
import Vehicle from "../models/vehicle.model.js";
import VehicleLog from "../models/vehicleLog.model.js";
import User from "../models/user.model.js";
import Announcement from "../models/announcement.model.js";

// Get comprehensive dashboard stats (Admin/Guard only)
const getDashboardStats = catchAsyncErrors(async (req, res, next) => {
  try {
    // Check permissions
    if (!['admin', 'guard'].includes(req.user.role)) {
      return next(new ErrorHandler('Access denied', 403));
    }

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);

    // Vehicle Statistics
    const vehicleStats = {
      total: await Vehicle.countDocuments(),
      inside: await Vehicle.countDocuments({ status: 'inside' }),
      exited: await Vehicle.countDocuments({ status: 'exited' }),
      today: {
        entries: await Vehicle.countDocuments({
          entryTime: { $gte: today },
          status: 'inside'
        }),
        exits: await Vehicle.countDocuments({
          exitTime: { $gte: today }
        }),
      },
      yesterday: {
        entries: await Vehicle.countDocuments({
          entryTime: { $gte: yesterday, $lt: today }
        }),
        exits: await Vehicle.countDocuments({
          exitTime: { $gte: yesterday, $lt: today }
        }),
      },
    };

    // User Statistics
    const userStats = {
      total: await User.countDocuments(),
      students: await User.countDocuments({ designation: 'Student' }),
      faculty: await User.countDocuments({ designation: 'Faculty' }),
      staff: await User.countDocuments({ designation: 'Staff' }),
      visitors: await User.countDocuments({ designation: 'Visitor' }),
      verified: await User.countDocuments({ isAccountVerified: true }),
      newThisWeek: await User.countDocuments({
        createdAt: { $gte: weekAgo }
      }),
    };

    // Peak Hours Analysis
    const peakHours = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: weekAgo },
          action: { $in: ['entry', 'exit'] }
        }
      },
      {
        $group: {
          _id: { $hour: '$timestamp' },
          count: { $sum: 1 }
        }
      },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);

    // Vehicle Type Distribution
    const vehicleTypeDistribution = await Vehicle.aggregate([
      {
        $group: {
          _id: '$vehicleType',
          count: { $sum: 1 }
        }
      },
      { $sort: { count: -1 } }
    ]);

    // Department-wise Vehicle Count
    const departmentStats = await Vehicle.aggregate([
      {
        $match: { department: { $exists: true, $ne: null } }
      },
      {
        $group: {
          _id: '$department',
          total: { $sum: 1 },
          inside: {
            $sum: { $cond: [{ $eq: ['$status', 'inside'] }, 1, 0] }
          }
        }
      },
      { $sort: { total: -1 } },
      { $limit: 10 }
    ]);

    // Recent Activity Summary
    const recentActivity = await VehicleLog.find()
      .populate('performedBy', 'name role')
      .sort({ timestamp: -1 })
      .limit(10)
      .select('vehicleNumber action timestamp gateName performedBy');

    // Gate-wise Statistics
    const gateStats = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: today },
          action: { $in: ['entry', 'exit'] }
        }
      },
      {
        $group: {
          _id: '$gateName',
          entries: {
            $sum: { $cond: [{ $eq: ['$action', 'entry'] }, 1, 0] }
          },
          exits: {
            $sum: { $cond: [{ $eq: ['$action', 'exit'] }, 1, 0] }
          },
          total: { $sum: 1 }
        }
      },
      { $sort: { total: -1 } }
    ]);

    // Average Duration Analysis
    const avgDuration = await Vehicle.aggregate([
      {
        $match: {
          status: 'exited',
          duration: { $gt: 0 }
        }
      },
      {
        $group: {
          _id: null,
          avgMinutes: { $avg: '$duration' },
          maxMinutes: { $max: '$duration' },
          minMinutes: { $min: '$duration' }
        }
      }
    ]);

    // Active Announcements Count
    const activeAnnouncements = await Announcement.countDocuments({
      isActive: true,
      expiresAt: { $gt: now }
    });

    // Weekly Trend
    const weeklyTrend = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: weekAgo },
          action: { $in: ['entry', 'exit'] }
        }
      },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } },
            action: '$action'
          },
          count: { $sum: 1 }
        }
      },
      {
        $group: {
          _id: '$_id.date',
          entries: {
            $sum: { $cond: [{ $eq: ['$_id.action', 'entry'] }, '$count', 0] }
          },
          exits: {
            $sum: { $cond: [{ $eq: ['$_id.action', 'exit'] }, '$count', 0] }
          }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.status(200).json({
      success: true,
      dashboard: {
        overview: {
          vehiclesInside: vehicleStats.inside,
          totalVehiclesToday: vehicleStats.today.entries,
          totalExitsToday: vehicleStats.today.exits,
          activeAnnouncements,
        },
        vehicleStats,
        userStats,
        peakHours,
        vehicleTypeDistribution,
        departmentStats,
        gateStats,
        recentActivity,
        weeklyTrend,
        averageDuration: avgDuration[0] || { avgMinutes: 0, maxMinutes: 0, minMinutes: 0 },
        lastUpdated: now,
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get real-time stats for dashboard updates
const getRealTimeStats = catchAsyncErrors(async (req, res, next) => {
  try {
    if (!['admin', 'guard'].includes(req.user.role)) {
      return next(new ErrorHandler('Access denied', 403));
    }

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const stats = {
      vehiclesInside: await Vehicle.countDocuments({ status: 'inside' }),
      entriesToday: await Vehicle.countDocuments({
        entryTime: { $gte: today },
        status: 'inside'
      }),
      exitsToday: await Vehicle.countDocuments({
        exitTime: { $gte: today }
      }),
      timestamp: now,
    };

    res.status(200).json({
      success: true,
      realTimeStats: stats,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get security alerts and notifications
const getSecurityAlerts = catchAsyncErrors(async (req, res, next) => {
  try {
    if (!['admin', 'guard'].includes(req.user.role)) {
      return next(new ErrorHandler('Access denied', 403));
    }

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    // Vehicles that have been inside for more than 12 hours
    const longStayVehicles = await Vehicle.find({
      status: 'inside',
      entryTime: { $lt: new Date(now.getTime() - 12 * 60 * 60 * 1000) }
    }).select('vehicleNumber ownerName entryTime vehicleType department')
      .sort({ entryTime: 1 })
      .limit(10);

    // Suspicious activity - multiple entries/exits by same vehicle
    const suspiciousActivity = await VehicleLog.aggregate([
      {
        $match: {
          timestamp: { $gte: today },
          action: { $in: ['entry', 'exit'] }
        }
      },
      {
        $group: {
          _id: '$vehicleNumber',
          activities: { $sum: 1 },
          lastActivity: { $max: '$timestamp' }
        }
      },
      {
        $match: { activities: { $gt: 6 } }
      },
      { $sort: { activities: -1 } },
      { $limit: 5 }
    ]);

    // Recent unauthorized attempts (if any)
    const unauthorizedAttempts = await VehicleLog.find({
      action: 'unauthorized_attempt',
      timestamp: { $gte: new Date(now.getTime() - 24 * 60 * 60 * 1000) }
    }).populate('performedBy', 'name role')
      .sort({ timestamp: -1 })
      .limit(5);

    res.status(200).json({
      success: true,
      alerts: {
        longStayVehicles,
        suspiciousActivity,
        unauthorizedAttempts,
        alertCount: longStayVehicles.length + suspiciousActivity.length + unauthorizedAttempts.length,
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

export {
  getDashboardStats,
  getRealTimeStats,
  getSecurityAlerts,
};