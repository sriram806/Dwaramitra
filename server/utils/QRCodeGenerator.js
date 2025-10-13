import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../config/env.js';

// Generate QR code data for vehicle entry
export const generateVehicleQRCode = (vehicleData) => {
  try {
    const qrData = {
      vehicleNumber: vehicleData.vehicleNumber,
      ownerName: vehicleData.ownerName,
      vehicleType: vehicleData.vehicleType,
      department: vehicleData.department,
      universityId: vehicleData.universityId,
      timestamp: Date.now(),
      // Security hash to prevent tampering
      hash: crypto
        .createHash('sha256')
        .update(`${vehicleData.vehicleNumber}-${vehicleData.universityId}-${Date.now()}`)
        .digest('hex')
        .substring(0, 16),
    };

    // Create JWT token for the QR code
    const token = jwt.sign(qrData, JWT_SECRET, { expiresIn: '24h' });
    
    return {
      success: true,
      qrToken: token,
      qrData,
      displayText: `${vehicleData.vehicleNumber} - ${vehicleData.ownerName}`,
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
    };
  }
};

// Verify QR code data
export const verifyVehicleQRCode = (qrToken) => {
  try {
    const decoded = jwt.verify(qrToken, JWT_SECRET);
    
    // Check if QR code is not too old (additional security)
    const tokenAge = Date.now() - decoded.timestamp;
    const maxAge = 24 * 60 * 60 * 1000; // 24 hours

    if (tokenAge > maxAge) {
      return {
        success: false,
        error: 'QR code has expired',
      };
    }

    return {
      success: true,
      vehicleData: decoded,
    };
  } catch (error) {
    return {
      success: false,
      error: 'Invalid or expired QR code',
    };
  }
};

// Generate entry pass with time-based validation
export const generateEntryPass = (vehicleData, validityHours = 24) => {
  const passData = {
    vehicleNumber: vehicleData.vehicleNumber,
    ownerName: vehicleData.ownerName,
    universityId: vehicleData.universityId,
    issueTime: Date.now(),
    validUntil: Date.now() + (validityHours * 60 * 60 * 1000),
    passId: crypto.randomBytes(8).toString('hex').toUpperCase(),
  };

  const passToken = jwt.sign(passData, JWT_SECRET, { 
    expiresIn: `${validityHours}h` 
  });

  return {
    success: true,
    passToken,
    passData,
    passId: passData.passId,
  };
};

// Validate entry pass
export const validateEntryPass = (passToken) => {
  try {
    const decoded = jwt.verify(passToken, JWT_SECRET);
    
    if (Date.now() > decoded.validUntil) {
      return {
        success: false,
        error: 'Entry pass has expired',
      };
    }

    return {
      success: true,
      passData: decoded,
    };
  } catch (error) {
    return {
      success: false,
      error: 'Invalid or expired entry pass',
    };
  }
};