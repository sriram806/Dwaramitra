import express from "express";
import {
  getDashboardStats,
  getRealTimeStats,
  getSecurityAlerts,
} from "../controllers/dashboard.controller.js";
import isAuthenticated from "../middleware/isAuthenticated.js";

const dashboardRouter = express.Router();

dashboardRouter.use(isAuthenticated);

// Get comprehensive dashboard statistics
dashboardRouter.get("/stats", getDashboardStats);

// Get real-time statistics for live updates
dashboardRouter.get("/realtime", getRealTimeStats);

// Get security alerts and notifications
dashboardRouter.get("/alerts", getSecurityAlerts);

export default dashboardRouter;