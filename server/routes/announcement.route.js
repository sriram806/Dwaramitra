import express from "express";
import {
  createAnnouncement,
  getActiveAnnouncements,
  markAnnouncementAsRead,
  getAllAnnouncements,
  updateAnnouncement,
  deleteAnnouncement,
} from "../controllers/announcement.controller.js";
import isAuthenticated from "../middleware/isAuthenticated.js";

const announcementRouter = express.Router();

announcementRouter.use(isAuthenticated);

// Public routes (for authenticated users)
announcementRouter.get("/active", getActiveAnnouncements);
announcementRouter.post("/:id/read", markAnnouncementAsRead);

// Admin only routes
announcementRouter.post("/", createAnnouncement);
announcementRouter.get("/all", getAllAnnouncements);
announcementRouter.put("/:id", updateAnnouncement);
announcementRouter.delete("/:id", deleteAnnouncement);

export default announcementRouter;