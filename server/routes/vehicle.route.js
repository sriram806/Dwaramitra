import express from "express";
import {
  addVehicle,
  getAllVehicles,
  getVehicleById,
  exitVehicle,
  updateVehicle,
  deleteVehicle,
  getVehicleStats,
  getRecentActivities,
} from "../controllers/vehicle.controller.js";
import isAuthenticated from "../middleware/isAuthenticated.js";


const vehicleRouter = express.Router();

vehicleRouter.use(isAuthenticated);

vehicleRouter.post("/add", addVehicle);
vehicleRouter.get("/", getAllVehicles);
vehicleRouter.get("/stats", getVehicleStats);
vehicleRouter.get("/recent-activities", getRecentActivities);
vehicleRouter.get("/:id", getVehicleById);
vehicleRouter.put("/:id", updateVehicle);
vehicleRouter.delete("/:id", deleteVehicle);

// Vehicle operations
vehicleRouter.post("/:id/exit", exitVehicle);

export default vehicleRouter;