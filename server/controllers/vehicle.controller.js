import Vehicle from '../models/vehicle.model.js';
import VehicleLog from '../models/vehicleLog.model.js';
import catchAsyncErrors from '../middleware/catchAsyncErrors.js';
import ErrorHandler from '../utils/ErrorHandler.js';

// Add new vehicle
export const addVehicle = catchAsyncErrors(async (req, res, next) => {
  const {
    vehicleNumber,
    vehicleType,
    ownerName,
    ownerRole,
    universityId,
    department,
    contactNumber,
    gateName,
    purpose,
    notes
  } = req.body;

  // Validate required fields
  if (!vehicleNumber || !vehicleType || !ownerName || !ownerRole || !contactNumber || !gateName) {
    return next(new ErrorHandler('All required fields must be provided', 400));
  }

  // Purpose is not required for faculty
  if (ownerRole !== 'faculty' && !purpose) {
    return next(new ErrorHandler('Purpose is required for non-faculty members', 400));
  }

  // Validate gate name
  if (!['GATE 1', 'GATE 2'].includes(gateName)) {
    return next(new ErrorHandler('Invalid gate. Must be GATE 1 or GATE 2', 400));
  }

  // Check if vehicle already exists and is currently inside
  const existingVehicle = await Vehicle.findOne({
    vehicleNumber: vehicleNumber.toUpperCase(),
    status: 'inside'
  });

  if (existingVehicle) {
    return next(new ErrorHandler('Vehicle is already inside the premises', 400));
  }

  // Create new vehicle entry
  const vehicle = new Vehicle({
    vehicleNumber: vehicleNumber.toUpperCase(),
    vehicleType,
    ownerName,
    ownerRole,
    universityId,
    department,
    contactNumber,
    entryTime: new Date(),
    gateName,
    status: 'inside',
    duration: 0,
    purpose,
    verifiedBy: req.user.id,
    notes
  });

  await vehicle.save();

  // Also create a vehicle log entry
  const vehicleLog = new VehicleLog({
    vehicleNumber: vehicleNumber.toUpperCase(),
    vehicleType,
    ownerName,
    ownerRole,
    universityId,
    department,
    contactNumber,
    entryTime: new Date(),
    gateName,
    guardId: req.user.id,
    purpose,
    notes
  });

  await vehicleLog.save();

  // Emit real-time update
  if (req.app.locals.io) {
    req.app.locals.io.emit('vehicleAdded', { vehicle, log: vehicleLog });
  }

  res.status(201).json({
    success: true,
    message: 'Vehicle entry logged successfully',
    vehicle
  });
});

// Get all vehicles with optional filters
export const getAllVehicles = catchAsyncErrors(async (req, res, next) => {
  const {
    status,
    vehicleType,
    search,
    page = 1,
    limit = 20,
    sortBy = 'entryTime',
    sortOrder = 'desc'
  } = req.query;

  // Build query
  const query = {};
  
  if (status) {
    query.status = status;
  }
  
  if (vehicleType) {
    query.vehicleType = vehicleType;
  }
  
  if (search) {
    query.$or = [
      { vehicleNumber: { $regex: search, $options: 'i' } },
      { ownerName: { $regex: search, $options: 'i' } },
      { contactNumber: { $regex: search, $options: 'i' } }
    ];
  }

  // Calculate pagination
  const pageNum = parseInt(page);
  const limitNum = parseInt(limit);
  const skip = (pageNum - 1) * limitNum;

  // Build sort object
  const sort = {};
  sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

  // Execute query
  const vehicles = await Vehicle.find(query)
    .sort(sort)
    .skip(skip)
    .limit(limitNum)
    .lean();

  // Get total count for pagination
  const total = await Vehicle.countDocuments(query);
  const totalPages = Math.ceil(total / limitNum);

  res.status(200).json({
    success: true,
    vehicles,
    pagination: {
      currentPage: pageNum,
      totalPages,
      total,
      hasNext: pageNum < totalPages,
      hasPrev: pageNum > 1
    }
  });
});

// Get single vehicle by ID
export const getVehicleById = catchAsyncErrors(async (req, res, next) => {
  const { id } = req.params;

  const vehicle = await Vehicle.findById(id);

  if (!vehicle) {
    return next(new ErrorHandler('Vehicle not found', 404));
  }

  res.status(200).json({
    success: true,
    vehicle
  });
});

// Update vehicle
export const updateVehicle = catchAsyncErrors(async (req, res, next) => {
  const { id } = req.params;
  const updateData = req.body;

  // Don't allow updating certain fields
  delete updateData._id;
  delete updateData.entryTime;
  delete updateData.exitTime;
  delete updateData.createdAt;

  const vehicle = await Vehicle.findByIdAndUpdate(
    id,
    { ...updateData, updatedAt: new Date() },
    { new: true, runValidators: true }
  );

  if (!vehicle) {
    return next(new ErrorHandler('Vehicle not found', 404));
  }

  // Emit real-time update
  if (req.app.locals.io) {
    req.app.locals.io.emit('vehicleUpdated', { vehicle });
  }

  res.status(200).json({
    success: true,
    message: 'Vehicle updated successfully',
    vehicle
  });
});

// Exit vehicle (mark as exited)
export const exitVehicle = catchAsyncErrors(async (req, res, next) => {
  const { id } = req.params;

  const vehicle = await Vehicle.findById(id);

  if (!vehicle) {
    return next(new ErrorHandler('Vehicle not found', 404));
  }

  if (vehicle.status === 'exited') {
    return next(new ErrorHandler('Vehicle has already exited', 400));
  }

  const exitTime = new Date();
  const duration = Math.floor((exitTime - vehicle.entryTime) / (1000 * 60)); // duration in minutes

  vehicle.exitTime = exitTime;
  vehicle.status = 'exited';
  vehicle.duration = duration;
  vehicle.updatedAt = new Date();

  await vehicle.save();

  // Update corresponding vehicle log
  await VehicleLog.findOneAndUpdate(
    { vehicleNumber: vehicle.vehicleNumber, exitTime: null },
    { 
      exitTime,
      duration,
      updatedAt: new Date()
    }
  );

  // Emit real-time update
  if (req.app.locals.io) {
    req.app.locals.io.emit('vehicleExited', { vehicle });
  }

  res.status(200).json({
    success: true,
    message: 'Vehicle exit logged successfully',
    vehicle
  });
});

// Delete vehicle
export const deleteVehicle = catchAsyncErrors(async (req, res, next) => {
  const { id } = req.params;

  const vehicle = await Vehicle.findByIdAndDelete(id);

  if (!vehicle) {
    return next(new ErrorHandler('Vehicle not found', 404));
  }

  // Also delete corresponding vehicle log if vehicle hasn't exited
  if (vehicle.status === 'inside') {
    await VehicleLog.findOneAndDelete({
      vehicleNumber: vehicle.vehicleNumber,
      exitTime: null
    });
  }

  // Emit real-time update
  if (req.app.locals.io) {
    req.app.locals.io.emit('vehicleDeleted', { vehicleId: id });
  }

  res.status(200).json({
    success: true,
    message: 'Vehicle deleted successfully'
  });
});

// Get vehicle statistics
export const getVehicleStats = catchAsyncErrors(async (req, res, next) => {
  const totalVehicles = await Vehicle.countDocuments();
  const parkedVehicles = await Vehicle.countDocuments({ status: 'inside' });
  const exitedVehicles = await Vehicle.countDocuments({ status: 'exited' });

  // Get vehicle type breakdown
  const vehicleTypeStats = await Vehicle.aggregate([
    {
      $group: {
        _id: '$vehicleType',
        count: { $sum: 1 }
      }
    }
  ]);

  // Get today's entries
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);

  const todayEntries = await Vehicle.countDocuments({
    entryTime: { $gte: today, $lt: tomorrow }
  });

  res.status(200).json({
    success: true,
    stats: {
      total: totalVehicles,
      parked: parkedVehicles,
      exited: exitedVehicles,
      todayEntries,
      vehicleTypes: vehicleTypeStats
    }
  });
});

// Get vehicle activities/recent entries
export const getVehicleActivities = catchAsyncErrors(async (req, res, next) => {
  const { limit = 10 } = req.query;

  const activities = await Vehicle.find()
    .sort({ entryTime: -1 })
    .limit(parseInt(limit))
    .select('vehicleNumber ownerName vehicleType entryTime exitTime status gateName')
    .lean();

  res.status(200).json({
    success: true,
    activities
  });
});