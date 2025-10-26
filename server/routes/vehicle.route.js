import express from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { authorize } from '../middleware/authorize.middleware.js';
import {
  addVehicle,
  getAllVehicles,
  getVehicleById,
  updateVehicle,
  deleteVehicle,
  exitVehicle,
  getVehicleStats,
  getVehicleActivities
} from '../controllers/vehicle.controller.js';

const router = express.Router();

// Protect all routes with authentication
router.use(authenticate);

// Add new vehicle
router.post('/add',
  authenticate,
  authorize(['guard', 'admin', 'officer']),
  addVehicle
);

// Get all vehicles with optional filters
router.get('/',
  authenticate,
  getAllVehicles
);

// Get vehicle statistics
router.get('/stats',
  authenticate,
  getVehicleStats
);

// Get vehicle activities
router.get('/activities',
  authenticate,
  getVehicleActivities
);

// Get single vehicle by ID
router.get('/:id',
  authenticate,
  getVehicleById
);

// Update vehicle
router.put('/:id',
  authenticate,
  authorize(['guard', 'admin', 'officer']),
  updateVehicle
);

// Exit vehicle (mark as exited)
router.put('/exit/:id',
  authenticate,
  authorize(['guard', 'admin', 'officer']),
  exitVehicle
);

// Delete vehicle
router.delete('/:id',
  authenticate,
  authorize(['admin', 'officer']),
  deleteVehicle
);

export default router;