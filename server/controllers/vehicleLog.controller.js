import Vehicle from '../models/vehicle.model.js';
import VehicleLog from '../models/vehicleLog.model.js';
import { ErrorHandler } from '../utils/error.js';
import { io } from '../app.js'; // Import socket.io instance

// Log vehicle entry
export const logVehicleEntry = async (req, res, next) => {
  try {
    const { 
      vehicleNumber,
      vehicleType,
      ownerName,
      ownerType, // This maps to ownerRole in Vehicle model
      contactNumber,
      purpose,
      entryGate,
      entryShift,
      entryGuard,
      notes,
      department,
      universityId
    } = req.body;
    
    console.log('Received vehicle entry data:', req.body);
    
    // Validate required fields
    if (!vehicleNumber || !vehicleType || !ownerName || !ownerType || !contactNumber) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: vehicleNumber, vehicleType, ownerName, ownerType, contactNumber'
      });
    }

    // Validate gate name
    if (entryGate && !['GATE 1', 'GATE 2'].includes(entryGate)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid gate. Must be GATE 1 or GATE 2'
      });
    }

    // Purpose is not required for faculty
    if (ownerType !== 'faculty' && !purpose) {
      return res.status(400).json({
        success: false,
        message: 'Purpose is required for non-faculty members'
      });
    }
    
    const entryBy = req.user._id;
    const guardInfo = {
      id: req.user._id,
      name: req.user.name
    };

    // Check if vehicle already exists and is currently inside
    const existingVehicle = await Vehicle.findOne({
      vehicleNumber: vehicleNumber.toUpperCase(),
      status: 'inside'
    });

    if (existingVehicle) {
      return res.status(400).json({
        success: false,
        message: 'Vehicle is already inside the premises'
      });
    }

    // Create new vehicle entry
    const vehicle = new Vehicle({
      vehicleNumber: vehicleNumber.toUpperCase(),
      vehicleType,
      ownerName,
      ownerRole: ownerType, // Map ownerType to ownerRole
      universityId,
      department,
      contactNumber,
      entryTime: new Date(),
      gateName: entryGate || 'GATE 1',
      status: 'inside',
      duration: 0,
      purpose: purpose || '',
      verifiedBy: entryBy,
      notes: notes || ''
    });

    await vehicle.save();

    // Create vehicle log entry
    const logEntry = new VehicleLog({
      vehicle: vehicle._id,
      vehicleNumber: vehicleNumber.toUpperCase(),
      vehicleType,
      ownerName,
      ownerType,
      universityId,
      department,
      contactNumber,
      purpose: purpose || '',
      notes: notes || '',
      entryBy,
      entryGuard: guardInfo,
      entryGate: entryGate || 'GATE 1',
      entryShift: entryShift || 'Day Shift',
      entryTime: new Date(),
      status: 'parked'
    });

    await logEntry.save();

    // Emit real-time update
    if (io) {
      io.emit('vehicle:entry', {
        type: 'NEW_ENTRY',
        data: logEntry
      });
      
      // Update dashboard stats
      updateDashboardStats();
    }

    res.status(201).json({
      success: true,
      message: 'Vehicle entry logged successfully',
      data: logEntry
    });
  } catch (error) {
    next(error);
  }
};

// Log vehicle exit
export const logVehicleExit = async (req, res, next) => {
  try {
    const { logId } = req.params;
    const { exitGate } = req.body;
    const exitBy = req.user.id;
    const exitGuard = {
      id: req.user._id,
      name: req.user.name
    };

    const logEntry = await VehicleLog.findById(logId);

    if (!logEntry) {
      return next(new ErrorHandler('Log entry not found', 404));
    }

    if (logEntry.status === 'exited') {
      return next(new ErrorHandler('Vehicle already exited', 400));
    }

    logEntry.exitTime = new Date();
    logEntry.exitBy = exitBy;
    logEntry.exitGate = exitGate;
    logEntry.exitGuard = exitGuard;
    logEntry.status = 'exited';

    await logEntry.save();

    // Emit real-time update
    if (io) {
      io.emit('vehicle:exit', {
        type: 'VEHICLE_EXIT',
        data: logEntry
      });
      
      // Update dashboard stats
      updateDashboardStats();
    }

    res.status(200).json({
      success: true,
      message: 'Vehicle exit logged successfully',
      data: logEntry
    });
  } catch (error) {
    next(error);
  }
};

// Get all vehicle logs with advanced filtering
export const getVehicleLogs = async (req, res, next) => {
  try {
    const { 
      status, 
      startDate, 
      endDate, 
      vehicleNumber, 
      ownerType, 
      entryGate, 
      entryShift,
      page = 1,
      limit = 20
    } = req.query;
    
    const query = {};

    if (status) {
      query.status = status;
    }

    if (vehicleNumber) {
      query.vehicleNumber = { $regex: vehicleNumber, $options: 'i' };
    }
    
    if (ownerType) {
      query.ownerType = ownerType;
    }
    
    if (entryGate) {
      query.entryGate = entryGate.toLowerCase();
    }
    
    if (entryShift) {
      query.entryShift = entryShift.toLowerCase();
    }

    if (startDate || endDate) {
      query.entryTime = {};
      if (startDate) {
        query.entryTime.$gte = new Date(startDate);
      }
      if (endDate) {
        query.entryTime.$lte = new Date(endDate);
      }
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [logs, total] = await Promise.all([
      VehicleLog.find(query)
        .sort({ entryTime: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('vehicle', 'vehicleNumber vehicleType ownerName')
        .populate('entryBy', 'name email')
        .populate('exitBy', 'name email'),
      VehicleLog.countDocuments(query)
    ]);
    
    const totalPages = Math.ceil(total / parseInt(limit));

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      page: parseInt(page),
      totalPages,
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

// Get current parked vehicles with filtering
export const getParkedVehicles = async (req, res, next) => {
  try {
    const { entryGate, ownerType } = req.query;
    const query = { status: 'parked' };
    
    if (entryGate) {
      query.entryGate = entryGate.toLowerCase();
    }
    
    if (ownerType) {
      query.ownerType = ownerType.toLowerCase();
    }
    
    const vehicles = await VehicleLog.find(query)
      .populate('vehicle', 'vehicleNumber vehicleType ownerName')
      .populate('entryGuard.id', 'name')
      .sort({ entryTime: -1 });

    res.status(200).json({
      success: true,
      count: vehicles.length,
      data: vehicles
    });
  } catch (error) {
    next(error);
  }
};

// Get dashboard statistics
export const getDashboardStats = async (req, res, next) => {
  try {
    const [
      totalEntriesToday,
      currentParked,
      byOwnerType,
      byGate,
      recentEntries
    ] = await Promise.all([
      // Total entries today
      VehicleLog.countDocuments({
        entryTime: { 
          $gte: new Date().setHours(0, 0, 0, 0),
          $lt: new Date()
        }
      }),
      
      // Currently parked vehicles
      VehicleLog.countDocuments({ status: 'parked' }),
      
      // Count by owner type
      VehicleLog.aggregate([
        { $group: { _id: '$ownerType', count: { $sum: 1 } } }
      ]),
      
      // Count by gate
      VehicleLog.aggregate([
        { $group: { _id: '$entryGate', count: { $sum: 1 } } }
      ]),
      
      // Recent entries
      VehicleLog.find()
        .sort({ entryTime: -1 })
        .limit(5)
        .populate('vehicle', 'vehicleNumber vehicleType')
        .populate('entryGuard.id', 'name')
    ]);

    res.status(200).json({
      success: true,
      data: {
        totalEntriesToday,
        currentParked,
        byOwnerType: byOwnerType.reduce((acc, curr) => ({
          ...acc,
          [curr._id]: curr.count
        }), {}),
        byGate: byGate.reduce((acc, curr) => ({
          ...acc,
          [curr._id]: curr.count
        }), {}),
        recentEntries
      }
    });
  } catch (error) {
    next(error);
  }
};

// Helper function to update dashboard stats via WebSocket
const updateDashboardStats = async () => {
  try {
    const stats = await getDashboardStats({}, { json: () => {} }, () => {});
    if (io) {
      io.emit('dashboard:update', {
        type: 'STATS_UPDATE',
        data: stats.data
      });
    }
  } catch (error) {
    console.error('Error updating dashboard stats:', error);
  }
};

// Get single log entry
export const getLogById = async (req, res, next) => {
  try {
    const log = await VehicleLog.findById(req.params.id)
      .populate('vehicle', 'vehicleNumber vehicleType ownerName')
      .populate('entryBy', 'name email')
      .populate('exitBy', 'name email');

    if (!log) {
      return next(new ErrorHandler('Log entry not found', 404));
    }

    res.status(200).json({
      success: true,
      data: log
    });
  } catch (error) {
    next(error);
  }
};

// Get logs by guard
export const getLogsByGuard = async (req, res, next) => {
  try {
    const { guardId } = req.params;
    const { page = 1, limit = 20, startDate, endDate } = req.query;

    const query = { 'entryGuard.id': guardId };
    
    if (startDate || endDate) {
      query.entryTime = {};
      if (startDate) query.entryTime.$gte = new Date(startDate);
      if (endDate) query.entryTime.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [logs, total] = await Promise.all([
      VehicleLog.find(query)
        .sort({ entryTime: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('vehicle', 'vehicleNumber vehicleType ownerName'),
      VehicleLog.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

// Get logs by gate
export const getLogsByGate = async (req, res, next) => {
  try {
    const { gate } = req.params;
    const { page = 1, limit = 20, startDate, endDate } = req.query;

    const query = { entryGate: gate.toLowerCase() };
    
    if (startDate || endDate) {
      query.entryTime = {};
      if (startDate) query.entryTime.$gte = new Date(startDate);
      if (endDate) query.entryTime.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [logs, total] = await Promise.all([
      VehicleLog.find(query)
        .sort({ entryTime: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('vehicle', 'vehicleNumber vehicleType ownerName'),
      VehicleLog.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

// Get logs by shift
export const getLogsByShift = async (req, res, next) => {
  try {
    const { shift } = req.params;
    const { page = 1, limit = 20, startDate, endDate } = req.query;

    const query = { entryShift: shift.toLowerCase() };
    
    if (startDate || endDate) {
      query.entryTime = {};
      if (startDate) query.entryTime.$gte = new Date(startDate);
      if (endDate) query.entryTime.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [logs, total] = await Promise.all([
      VehicleLog.find(query)
        .sort({ entryTime: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('vehicle', 'vehicleNumber vehicleType ownerName'),
      VehicleLog.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

// Get logs by date range
export const getLogsByDateRange = async (req, res, next) => {
  try {
    const { startDate, endDate, page = 1, limit = 20 } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date and end date are required'
      });
    }

    const query = {
      entryTime: {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      }
    };

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [logs, total] = await Promise.all([
      VehicleLog.find(query)
        .sort({ entryTime: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('vehicle', 'vehicleNumber vehicleType ownerName'),
      VehicleLog.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

// Get logs by vehicle type
export const getLogsByVehicleType = async (req, res, next) => {
  try {
    const { type } = req.params;
    const { page = 1, limit = 20, startDate, endDate } = req.query;

    // First get vehicles of the specified type
    const vehicles = await Vehicle.find({ 
      vehicleType: type.toLowerCase() 
    }).select('_id');
    
    const vehicleIds = vehicles.map(v => v._id);
    
    const query = { vehicle: { $in: vehicleIds } };
    
    if (startDate || endDate) {
      query.entryTime = {};
      if (startDate) query.entryTime.$gte = new Date(startDate);
      if (endDate) query.entryTime.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [logs, total] = await Promise.all([
      VehicleLog.find(query)
        .sort({ entryTime: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('vehicle', 'vehicleNumber vehicleType ownerName'),
      VehicleLog.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

// Export logs to CSV
export const exportLogsToCSV = async (req, res, next) => {
  try {
    const { startDate, endDate, status, ownerType, entryGate } = req.query;
    
    const query = {};
    
    if (status) query.status = status;
    if (ownerType) query.ownerType = ownerType;
    if (entryGate) query.entryGate = entryGate.toLowerCase();
    
    if (startDate || endDate) {
      query.entryTime = {};
      if (startDate) query.entryTime.$gte = new Date(startDate);
      if (endDate) query.entryTime.$lte = new Date(endDate);
    }

    const logs = await VehicleLog.find(query)
      .populate('vehicle', 'vehicleNumber vehicleType ownerName')
      .sort({ entryTime: -1 });

    // Convert to CSV format
    const csvHeaders = [
      'Vehicle Number',
      'Vehicle Type', 
      'Owner Name',
      'Owner Type',
      'Purpose',
      'Entry Time',
      'Exit Time',
      'Status',
      'Entry Gate',
      'Entry Shift',
      'Entry Guard',
      'Exit Guard'
    ].join(',');

    const csvRows = logs.map(log => [
      log.vehicleNumber,
      log.vehicle?.vehicleType || '',
      log.vehicle?.ownerName || '',
      log.ownerType,
      log.purpose,
      log.entryTime.toISOString(),
      log.exitTime ? log.exitTime.toISOString() : '',
      log.status,
      log.entryGate || '',
      log.entryShift || '',
      log.entryGuard?.name || '',
      log.exitGuard?.name || ''
    ].map(field => `"${field}"`).join(','));

    const csvContent = [csvHeaders, ...csvRows].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="vehicle_logs_${Date.now()}.csv"`);
    res.status(200).send(csvContent);
  } catch (error) {
    next(error);
  }
};

// Assign guard to gate
export const assignGuardToGate = async (req, res, next) => {
  try {
    const { guardId, gate, shift, startDate, endDate } = req.body;

    if (!guardId || !gate || !shift) {
      return res.status(400).json({
        success: false,
        message: 'Guard ID, gate, and shift are required'
      });
    }

    // Here you would implement the logic to assign a guard to a gate
    // This might involve updating a GuardSchedule model or similar
    // For now, we'll return a success response
    
    res.status(200).json({
      success: true,
      message: 'Guard assigned to gate successfully',
      data: {
        guardId,
        gate,
        shift,
        startDate,
        endDate,
        assignedBy: req.user.id,
        assignedAt: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
};

// Update guard shift
export const updateGuardShift = async (req, res, next) => {
  try {
    const { guardId } = req.params;
    const { shift, gate, startDate, endDate } = req.body;

    if (!shift) {
      return res.status(400).json({
        success: false,
        message: 'Shift is required'
      });
    }

    // Here you would implement the logic to update guard shift
    // This might involve updating a User model or GuardSchedule model
    
    res.status(200).json({
      success: true,
      message: 'Guard shift updated successfully',
      data: {
        guardId,
        shift,
        gate,
        startDate,
        endDate,
        updatedBy: req.user.id,
        updatedAt: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
};

// Get guard schedule
export const getGuardSchedule = async (req, res, next) => {
  try {
    const { guardId } = req.params;
    const { startDate, endDate } = req.query;

    // Here you would implement the logic to get guard schedule
    // This might involve querying a GuardSchedule model
    // For now, we'll return a mock response
    
    const schedule = {
      guardId: guardId || 'all',
      schedule: [
        {
          date: new Date().toISOString().split('T')[0],
          shift: 'day',
          gate: 'main',
          startTime: '08:00',
          endTime: '16:00'
        }
        // Add more schedule entries as needed
      ]
    };

    res.status(200).json({
      success: true,
      data: schedule
    });
  } catch (error) {
    next(error);
  }
};
