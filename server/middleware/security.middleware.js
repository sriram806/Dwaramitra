import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import xss from 'xss-clean';
import mongoSanitize from 'express-mongo-sanitize';
import hpp from 'hpp';
import { ErrorHandler } from '../utils/error.js';

// Rate limiting
const createRateLimiter = (windowMs, max, message) => {
  return rateLimit({
    windowMs,
    max,
    message: message || 'Too many requests, please try again later.',
    handler: (req, res) => {
      res.status(429).json({
        success: false,
        message: message || 'Too many requests, please try again later.'
      });
    }
  });
};

export const apiLimiter = createRateLimiter(15 * 60 * 1000, 100, 'Too many requests from this IP, please try again after 15 minutes');
export const authLimiter = createRateLimiter(60 * 60 * 1000, 5, 'Too many login attempts, please try again after an hour');

// Set security HTTP headers
export const securityHeaders = () => {
  return helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", 'trusted-cdn.com'],
        styleSrc: ["'self'", 'trusted-cdn.com', "'unsafe-inline'"],
        imgSrc: ["'self'", 'data:', 'trusted-cdn.com'],
        connectSrc: ["'self'", 'api.trusted.com'],
        fontSrc: ["'self'", 'trusted-cdn.com'],
        objectSrc: ["'none'"],
        upgradeInsecureRequests: []
      }
    },
    hsts: {
      maxAge: 31536000, // 1 year in seconds
      includeSubDomains: true,
      preload: true
    },
    frameguard: { action: 'deny' },
    noSniff: true,
    xssFilter: true,
    referrerPolicy: { policy: 'same-origin' }
  });
};

// Data sanitization against XSS
export const xssProtection = xss();

// Prevent parameter pollution
export const preventParameterPollution = hpp({
  whitelist: [
    'duration',
    'ratingsQuantity',
    'ratingsAverage',
    'maxGroupSize',
    'difficulty',
    'price',
    'sort',
    'limit',
    'page',
    'fields'
  ]
});

// Sanitize data
export const sanitizeData = mongoSanitize();

// Prevent NoSQL injection
export const preventNoSqlInjection = (req, res, next) => {
  const query = JSON.stringify(req.query);
  const body = JSON.stringify(req.body);
  
  const maliciousPatterns = [
    /\$[^\s]/g, // NoSQL injection patterns
    /\/\*.*\*\//g, // SQL comments
    /--/g, // SQL comments
    /;.*/g, // SQL injection
    /<script[^>]*>.*<\/script>/g, // XSS
    /on\w+\s*=\s*["'][^"']*["']/g, // Inline event handlers
    /javascript:/g, // JavaScript URLs
    /data:/g, // Data URLs
    /vbscript:/g, // VBScript URLs
  ];

  const checkForMaliciousInput = (input) => {
    return maliciousPatterns.some(pattern => pattern.test(input));
  };

  if (checkForMaliciousInput(query) || checkForMaliciousInput(body)) {
    return next(new ErrorHandler('Malicious input detected', 400));
  }

  // Remove any $ or . characters from request body to prevent NoSQL injection
  if (req.body) {
    const cleanBody = JSON.parse(JSON.stringify(req.body).replace(/\$/g, '').replace(/\./g, ''));
    req.body = cleanBody;
  }

  next();
};

// CORS configuration
export const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:4000',
      'http://localhost:5173',
      'http://localhost:8080',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:3001',
      'http://127.0.0.1:4000',
      'http://127.0.0.1:5173',
      'http://127.0.0.1:8080',
      'https://your-production-url.com'
    ];
    
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    // In development, allow any localhost origin
    if (process.env.NODE_ENV === 'development' && 
        (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:'))) {
      return callback(null, true);
    }
    
    if (allowedOrigins.indexOf(origin) === -1) {
      const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
      return callback(new Error(msg), false);
    }
    
    return callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 600 // 10 minutes
};

// Request validation middleware
export const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body, { abortEarly: false });
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors
      });
    }
    next();
  };
};

// Log all requests for debugging
export const requestLogger = (req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
};

// Error handling middleware
export const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  
  // Handle specific error types
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: 'Validation Error',
      errors: Object.values(err.errors).map(e => e.message)
    });
  }
  
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      message: 'Invalid token',
      error: 'Authentication failed'
    });
  }
  
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      message: 'Token expired',
      error: 'Authentication failed'
    });
  }
  
  // Default error handler
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? err.stack : {}
  });
};

// Route not found handler
export const notFound = (req, res) => {
  res.status(404).json({
    success: false,
    message: `Not Found - ${req.originalUrl}`
  });
};

export default {
  apiLimiter,
  authLimiter,
  securityHeaders,
  xssProtection,
  preventParameterPollution,
  sanitizeData,
  preventNoSqlInjection,
  corsOptions,
  validateRequest,
  requestLogger,
  errorHandler,
  notFound
};
