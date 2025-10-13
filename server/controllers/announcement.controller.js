import ErrorHandler from "../utils/ErrorHandler.js";
import catchAsyncErrors from "../middleware/catchAsyncErrors.js";
import Announcement from "../models/announcement.model.js";

// Create announcement (Admin only)
const createAnnouncement = catchAsyncErrors(async (req, res, next) => {
  try {
    const {
      title,
      message,
      type,
      priority,
      targetAudience,
      expiresAt,
    } = req.body;

    // Only admins can create announcements
    if (req.user.role !== 'admin') {
      return next(new ErrorHandler('Only admins can create announcements', 403));
    }

    const announcement = await Announcement.create({
      title,
      message,
      type,
      priority,
      targetAudience: targetAudience || ['all'],
      expiresAt: expiresAt || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // Default 7 days
      createdBy: req.user._id,
    });

    // Emit real-time notification via Socket.IO
    if (req.app.locals.io) {
      req.app.locals.io.emit('new-announcement', {
        id: announcement._id,
        title: announcement.title,
        message: announcement.message,
        type: announcement.type,
        priority: announcement.priority,
        targetAudience: announcement.targetAudience,
      });
    }

    res.status(201).json({
      success: true,
      message: 'Announcement created successfully',
      announcement,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get active announcements for user
const getActiveAnnouncements = catchAsyncErrors(async (req, res, next) => {
  try {
    const userRole = req.user.designation?.toLowerCase() || 'student';
    
    const announcements = await Announcement.find({
      isActive: true,
      expiresAt: { $gt: new Date() },
      $or: [
        { targetAudience: 'all' },
        { targetAudience: userRole },
        { targetAudience: { $in: [userRole, 'all'] } },
      ],
    })
      .populate('createdBy', 'name role')
      .sort({ priority: -1, createdAt: -1 });

    res.status(200).json({
      success: true,
      announcements,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Mark announcement as read
const markAnnouncementAsRead = catchAsyncErrors(async (req, res, next) => {
  try {
    const { id } = req.params;

    const announcement = await Announcement.findById(id);
    if (!announcement) {
      return next(new ErrorHandler('Announcement not found', 404));
    }

    // Check if already read
    const alreadyRead = announcement.readBy.some(
      item => item.user.toString() === req.user._id.toString()
    );

    if (!alreadyRead) {
      announcement.readBy.push({
        user: req.user._id,
        readAt: new Date(),
      });
      await announcement.save();
    }

    res.status(200).json({
      success: true,
      message: 'Announcement marked as read',
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Get all announcements (Admin only)
const getAllAnnouncements = catchAsyncErrors(async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return next(new ErrorHandler('Access denied', 403));
    }

    const { page = 1, limit = 10, isActive } = req.query;
    const query = {};

    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    const announcements = await Announcement.find(query)
      .populate('createdBy', 'name email role')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Announcement.countDocuments(query);

    res.status(200).json({
      success: true,
      announcements,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalAnnouncements: total,
      },
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Update announcement (Admin only)
const updateAnnouncement = catchAsyncErrors(async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return next(new ErrorHandler('Access denied', 403));
    }

    const { id } = req.params;
    const updates = req.body;

    const announcement = await Announcement.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    ).populate('createdBy', 'name email role');

    if (!announcement) {
      return next(new ErrorHandler('Announcement not found', 404));
    }

    res.status(200).json({
      success: true,
      message: 'Announcement updated successfully',
      announcement,
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

// Delete announcement (Admin only)
const deleteAnnouncement = catchAsyncErrors(async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return next(new ErrorHandler('Access denied', 403));
    }

    const { id } = req.params;

    const announcement = await Announcement.findByIdAndDelete(id);
    if (!announcement) {
      return next(new ErrorHandler('Announcement not found', 404));
    }

    res.status(200).json({
      success: true,
      message: 'Announcement deleted successfully',
    });
  } catch (error) {
    return next(new ErrorHandler(error.message, 500));
  }
});

export {
  createAnnouncement,
  getActiveAnnouncements,
  markAnnouncementAsRead,
  getAllAnnouncements,
  updateAnnouncement,
  deleteAnnouncement,
};