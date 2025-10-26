import express from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { authorize } from '../middleware/authorize.middleware.js';
import {
  getParkingAnalytics,
  getAuditTrail,
  exportAnalyticsToCSV,
  getSystemHealth
} from '../controllers/analytics.controller.js';

const router = express.Router();

// Protect all routes with authentication
router.use(authenticate);

// Get parking analytics
router.get('/parking', 
  authorize(['officer', 'admin']), 
  getParkingAnalytics
);

// Get audit trail
router.get('/audit-trail', 
  authorize(['officer', 'admin']), 
  getAuditTrail
);

// Export analytics data
router.get('/export', 
  authorize(['officer', 'admin']), 
  exportAnalyticsToCSV
);

// Get system health status
router.get('/system-health', 
  authorize(['admin']), 
  getSystemHealth
);

export default router;
