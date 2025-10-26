import express from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import {
  logVehicleEntry,
  logVehicleExit,
  getVehicleLogs,
  getParkedVehicles,
  getLogById,
  getDashboardStats,
  getLogsByGuard,
  getLogsByGate,
  getLogsByShift,
  getLogsByDateRange,
  getLogsByVehicleType,
  exportLogsToCSV,
  assignGuardToGate,
  updateGuardShift,
  getGuardSchedule
} from '../controllers/vehicleLog.controller.js';
import { authorize } from '../middleware/authorize.middleware.js';

const router = express.Router();

// Protect all routes with authentication
router.use(authenticate);

// Log vehicle entry
router.post('/entry',
  authenticate,
  authorize(['guard', 'admin']),
  logVehicleEntry
);

// Log vehicle exit
router.put('/exit/:logId',
  authenticate,
  authorize(['guard', 'admin']),
  logVehicleExit
);

// Get all vehicle logs with optional filters
router.get('/',
  authenticate,
  getVehicleLogs
);

// Get currently parked vehicles
router.get('/parked',
  authenticate,
  getParkedVehicles
);

// Get dashboard statistics
router.get('/stats',
  authenticate,
  getDashboardStats
);

// Get single log entry
router.get('/:id',
  authenticate,
  getLogById
);

// Guard assignment and scheduling
router.post('/assign-guard',
  authenticate,
  authorize(['officer', 'admin']),
  assignGuardToGate
);

router.put('/update-shift/:guardId',
  authenticate,
  authorize(['officer', 'admin']),
  updateGuardShift
);

router.get('/guard/schedule/:guardId?',
  authenticate,
  getGuardSchedule
);

// Reporting endpoints
router.get('/report/guard/:guardId',
  authenticate,
  getLogsByGuard
);

router.get('/report/gate/:gate',
  authenticate,
  getLogsByGate
);

router.get('/report/shift/:shift',
  authenticate,
  getLogsByShift
);

router.get('/report/date-range',
  authenticate,
  getLogsByDateRange
);

router.get('/report/vehicle-type/:type', authenticate, getLogsByVehicleType);

router.get('/export/csv', authenticate, authorize(['officer', 'admin']), exportLogsToCSV);

export default router;
