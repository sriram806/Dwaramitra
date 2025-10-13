import express from "express";
import {
  getVehicleLogs,
  getVehicleHistory,
  getActivityAnalytics,
} from "../controllers/vehicleLog.controller.js";
import isAuthenticated from "../middleware/isAuthenticated.js";

const vehicleLogRouter = express.Router();

vehicleLogRouter.use(isAuthenticated);

// Get vehicle logs with filters
vehicleLogRouter.get("/", getVehicleLogs);

// Get vehicle history by vehicle number
vehicleLogRouter.get("/history/:vehicleNumber", getVehicleHistory);

// Get activity analytics
vehicleLogRouter.get("/analytics", getActivityAnalytics);

export default vehicleLogRouter;