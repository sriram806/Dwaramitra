import VehicleLog from '../models/vehicleLog.model.js';
import AuditTrail from '../models/auditTrail.model.js';
import { ErrorHandler } from '../utils/error.js';
import moment from 'moment';
import { io } from '../app.js';

// Get parking analytics
export const getParkingAnalytics = async (req, res, next) => {
  try {
    const { startDate, endDate, groupBy = 'day' } = req.query;
    
    const defaultStartDate = moment().subtract(30, 'days').startOf('day');
    const defaultEndDate = moment().endOf('day');
    
    const dateFilter = {
      entryTime: {
        $gte: startDate ? new Date(startDate) : defaultStartDate.toDate(),
        $lte: endDate ? new Date(endDate) : defaultEndDate.toDate()
      }
    };

    // Get total entries by date range
    const totalEntries = await VehicleLog.countDocuments(dateFilter);
    
    // Get entries by vehicle type
    const byVehicleType = await VehicleLog.aggregate([
      { $match: dateFilter },
      { $group: { _id: '$vehicleType', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Get entries by owner type
    const byOwnerType = await VehicleLog.aggregate([
      { $match: dateFilter },
      { $group: { _id: '$ownerType', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Get entries by gate
    const byGate = await VehicleLog.aggregate([
      { $match: dateFilter },
      { $group: { _id: '$entryGate', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Get entries by shift
    const byShift = await VehicleLog.aggregate([
      { $match: dateFilter },
      { $group: { _id: '$entryShift', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Get hourly distribution
    const hourlyDistribution = await VehicleLog.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: { $hour: '$entryTime' },
          count: { $sum: 1 },
          avgDuration: { $avg: {
            $divide: [
              { $subtract: ['$exitTime', '$entryTime'] },
              1000 * 60 // Convert to minutes
            ]
          }}
        }
      },
      { $sort: { _id: 1 } }
    ]);

    // Get average parking duration by vehicle type
    const avgDurationByType = await VehicleLog.aggregate([
      { 
        $match: { 
          ...dateFilter,
          exitTime: { $exists: true }
        } 
      },
      {
        $group: {
          _id: '$vehicleType',
          avgDuration: {
            $avg: {
              $divide: [
                { $subtract: ['$exitTime', '$entryTime'] },
                1000 * 60 // Convert to minutes
              ]
            }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { avgDuration: -1 } }
    ]);

    // Get busiest days of week
    const byDayOfWeek = await VehicleLog.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: { $dayOfWeek: '$entryTime' },
          count: { $sum: 1 },
          day: { $first: { $dayOfWeek: '$entryTime' } }
        }
      },
      { $sort: { _id: 1 } },
      {
        $project: {
          _id: 0,
          day: 1,
          dayName: {
            $let: {
              vars: {
                daysInWeek: [null, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
              },
              in: { $arrayElemAt: ['$$daysInWeek', '$day'] }
            }
          },
          count: 1
        }
      }
    ]);

    // Get recent security events
    const recentSecurityEvents = await AuditTrail.find({
      action: { $in: ['AUTH_FAILURE', 'SYSTEM_EVENT'] },
      timestamp: { $gte: moment().subtract(7, 'days').toDate() }
    })
    .sort({ timestamp: -1 })
    .limit(10)
    .populate('performedBy', 'name email role')
    .lean();

    // Emit real-time update
    if (io) {
      io.emit('analytics:update', {
        type: 'ANALYTICS_UPDATE',
        data: {
          timestamp: new Date(),
          totalEntries,
          byVehicleType,
          byOwnerType,
          byGate,
          byShift,
          hourlyDistribution,
          avgDurationByType,
          byDayOfWeek,
          recentSecurityEvents
        }
      });
    }

    res.status(200).json({
      success: true,
      data: {
        summary: {
          totalEntries,
          timeRange: {
            start: dateFilter.entryTime.$gte,
            end: dateFilter.entryTime.$lte
          },
          byVehicleType,
          byOwnerType,
          byGate,
          byShift,
          hourlyDistribution,
          avgDurationByType,
          byDayOfWeek,
          recentSecurityEvents
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

// Get audit trail
export const getAuditTrail = async (req, res, next) => {
  try {
    const { 
      action, 
      entity, 
      entityId, 
      userId, 
      startDate, 
      endDate, 
      status,
      page = 1,
      limit = 50
    } = req.query;

    const query = {};
    
    if (action) query.action = action;
    if (entity) query.entity = entity;
    if (entityId) query.entityId = entityId;
    if (userId) query.performedBy = userId;
    if (status) query.status = status;
    
    // Date range filter
    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) query.timestamp.$gte = new Date(startDate);
      if (endDate) query.timestamp.$lte = new Date(endDate);
    }

    const options = {
      page: parseInt(page, 10),
      limit: parseInt(limit, 10),
      sort: { timestamp: -1 },
      populate: {
        path: 'performedBy',
        select: 'name email role'
      }
    };

    const result = await AuditTrail.paginate(query, options);

    res.status(200).json({
      success: true,
      data: {
        total: result.totalDocs,
        totalPages: result.totalPages,
        page: result.page,
        limit: result.limit,
        hasNextPage: result.hasNextPage,
        hasPrevPage: result.hasPrevPage,
        items: result.docs
      }
    });
  } catch (error) {
    next(error);
  }
};

// Export analytics to CSV
export const exportAnalyticsToCSV = async (req, res, next) => {
  try {
    const { type, ...filters } = req.query;
    let data, headers, filename;

    switch (type) {
      case 'vehicleLogs':
        data = await VehicleLog.find(filters)
          .populate('vehicle', 'vehicleNumber vehicleType')
          .populate('entryBy', 'name email')
          .lean();
        
        headers = [
          'Entry Time', 'Exit Time', 'Vehicle Number', 'Vehicle Type',
          'Owner Type', 'Purpose', 'Entry Gate', 'Exit Gate', 'Status'
        ];
        
        data = data.map(log => ({
          'Entry Time': log.entryTime?.toISOString() || '',
          'Exit Time': log.exitTime?.toISOString() || '',
          'Vehicle Number': log.vehicle?.vehicleNumber || 'N/A',
          'Vehicle Type': log.vehicle?.vehicleType || 'N/A',
          'Owner Type': log.ownerType || 'N/A',
          'Purpose': log.purpose || 'N/A',
          'Entry Gate': log.entryGate || 'N/A',
          'Exit Gate': log.exitGate || 'N/A',
          'Status': log.status || 'N/A'
        }));
        
        filename = `vehicle-logs-${new Date().toISOString().split('T')[0]}.csv`;
        break;

      case 'auditTrail':
        data = await AuditTrail.find(filters)
          .populate('performedBy', 'name email role')
          .lean();
        
        headers = [
          'Timestamp', 'Action', 'Entity', 'Entity ID',
          'Performed By', 'Status', 'IP Address'
        ];
        
        data = data.map(log => ({
          'Timestamp': log.timestamp?.toISOString() || '',
          'Action': log.action,
          'Entity': log.entity,
          'Entity ID': log.entityId || 'N/A',
          'Performed By': log.performedBy?.name || 'System',
          'Status': log.status,
          'IP Address': log.ipAddress || 'N/A'
        }));
        
        filename = `audit-trail-${new Date().toISOString().split('T')[0]}.csv`;
        break;

      default:
        throw new ErrorHandler('Invalid export type specified', 400);
    }

    // Convert to CSV
    let csv = headers.join(',') + '\n';
    
    data.forEach(item => {
      const row = headers.map(header => {
        const value = item[header] || '';
        return `"${value.toString().replace(/"/g, '""')}"`;
      });
      csv += row.join(',') + '\n';
    });

    // Set headers for file download
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    
    res.status(200).send(csv);
  } catch (error) {
    next(error);
  }
};

// Get system health status
export const getSystemHealth = async (req, res, next) => {
  try {
    // Check database connection
    const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
    
    // Check recent errors
    const recentErrors = await AuditTrail.countDocuments({
      status: 'FAILURE',
      timestamp: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } // Last 24 hours
    });
    
    // Get system stats
    const stats = await Promise.all([
      VehicleLog.countDocuments(),
      AuditTrail.countDocuments(),
      VehicleLog.estimatedDocumentSize(),
      AuditTrail.estimatedDocumentSize()
    ]);

    const [totalLogs, totalAudits, logsSize, auditsSize] = stats;
    
    res.status(200).json({
      success: true,
      data: {
        status: 'operational',
        uptime: process.uptime(),
        database: {
          status: dbStatus,
          totalLogs,
          totalAudits,
          storageUsed: {
            logs: `${(logsSize / (1024 * 1024)).toFixed(2)} MB`,
            audits: `${(auditsSize / (1024 * 1024)).toFixed(2)} MB`,
            total: `${((logsSize + auditsSize) / (1024 * 1024)).toFixed(2)} MB`
          }
        },
        recentErrors: {
          count: recentErrors,
          status: recentErrors > 100 ? 'warning' : 'normal'
        },
        lastUpdated: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
};
