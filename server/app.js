import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import cookieParser from 'cookie-parser';
import http from 'http';
import { Server } from 'socket.io';
import connecttoDatabase from './database/mongodb.js';
import { CLOUD_API_KEY, CLOUD_NAME, CLOUD_SECRET_KEY, PORT, NODE_ENV } from './config/env.js';
import { v2 as cloudinary } from 'cloudinary';
import { verifyToken } from './middleware/auth.middleware.js';
import {
  apiLimiter,
  authLimiter,
  securityHeaders,
  xssProtection,
  preventParameterPollution,
  sanitizeData,
  preventNoSqlInjection,
  corsOptions,
  requestLogger,
  errorHandler,
  notFound
} from './middleware/security.middleware.js';

// Initialize Express app
const app = express();

// Import routes
import authRouter from './routes/auth.route.js';
import userRoute from './routes/user.route.js';
import announcementRouter from './routes/announcement.route.js';
import vehicleLogRouter from './routes/vehicleLog.route.js';
import vehicleRouter from './routes/vehicle.route.js';
import analyticsRouter from './routes/analytics.route.js';
connecttoDatabase();

// Security Middleware
app.use(securityHeaders());
app.use(cors(corsOptions));
app.use(xssProtection);
app.use(preventParameterPollution);
app.use(sanitizeData);
app.use(preventNoSqlInjection);
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));
app.use(cookieParser());

app.use(requestLogger);

{/*// Rate limiting
app.use('/api/auth', authLimiter);
app.use('/api', apiLimiter);*/}

// Cloudinary config
cloudinary.config({
  cloud_name: CLOUD_NAME,
  api_key: CLOUD_API_KEY,
  api_secret: CLOUD_SECRET_KEY
});

// CORS
const allowedOrigins = [
  'http://localhost:5173',
  'http://localhost:3000',
  'https://flyobo.onrender.com',
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin) {
      return callback(null, true);
    }
    
    if (origin.startsWith('http://localhost:') || origin.startsWith('https://localhost:')) {
      return callback(null, true);
    }
    
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    // Block all other origins
    callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-auth-token', 'Origin', 'X-Requested-With', 'Accept'],
  credentials: true,
  preflightContinue: false,
  optionsSuccessStatus: 200,
  
}));
app.options('*', cors());

// Root Route
app.get('/', (req, res) => {
  res.send(`hii`);
});

// Routes
app.use('/api/auth', authRouter);
app.use('/api/user', userRoute);
app.use('/api/announcements', announcementRouter);
app.use('/api/vehicle-logs', vehicleLogRouter);
app.use('/api/vehicle', vehicleRouter);
app.use('/api/analytics', analyticsRouter);

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: NODE_ENV === 'production' 
      ? ['https://flyobo.com'] 
      : ['http://localhost:3000', 'http://localhost:5173'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization', 'x-auth-token']
  },
  transports: ['websocket', 'polling']
});

// Socket.IO authentication middleware
io.use((socket, next) => {
  const token = socket.handshake.auth.token || 
               socket.handshake.headers['x-auth-token'] ||
               socket.handshake.query.token;
  
  if (!token) {
    return next(new Error('Authentication error: No token provided'));
  }

  try {
    const decoded = verifyToken(token);
    socket.user = decoded;
    next();
  } catch (error) {
    return next(new Error('Authentication error: Invalid token'));
  }
});

io.on('connection', (socket) => {
  
  if (socket.user?.userId) {
    socket.join(`user_${socket.user.userId}`);
  }
  socket.join('global_updates');
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.user?.userId || 'unknown');
  });
});

app.set('io', io);
app.locals.io = io;

export { io };

const port = PORT || 3000;
server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
  console.log(`WebSocket server is running on port ${port}`);
  console.log(`Environment: ${NODE_ENV || 'development'}`);
});