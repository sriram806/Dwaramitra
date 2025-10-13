# 🚀 Vehicle Entry & Exit System - Deployment Guide

## 📋 Prerequisites

- Node.js (v16 or higher)
- MongoDB (v4.4 or higher)
- Git
- npm or yarn

## 🌐 Production Deployment Options

### Option 1: Render (Recommended for beginners)

1. **Prepare your code:**
   ```bash
   # Make sure your package.json has the start script
   npm install
   git add .
   git commit -m "Prepare for deployment"
   git push origin main
   ```

2. **Deploy on Render:**
   - Go to [render.com](https://render.com)
   - Connect your GitHub repository
   - Create a new Web Service
   - Set build command: `npm install`
   - Set start command: `npm start`
   - Add environment variables (see below)

3. **Set up MongoDB:**
   - Use MongoDB Atlas (cloud) or Railway MongoDB
   - Get connection string and add to MONGO_URI

### Option 2: Railway

1. **Deploy via CLI:**
   ```bash
   npm install -g @railway/cli
   railway login
   railway init
   railway up
   ```

2. **Add environment variables in Railway dashboard**

### Option 3: Heroku

1. **Install Heroku CLI and deploy:**
   ```bash
   npm install -g heroku
   heroku login
   heroku create your-app-name
   git push heroku main
   ```

2. **Set environment variables:**
   ```bash
   heroku config:set NODE_ENV=production
   heroku config:set MONGO_URI=your_mongodb_uri
   # Add other environment variables
   ```

### Option 4: VPS/Self-hosted

1. **Set up server (Ubuntu example):**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Install MongoDB
   wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
   echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
   sudo apt-get update
   sudo apt-get install -y mongodb-org
   
   # Start MongoDB
   sudo systemctl start mongod
   sudo systemctl enable mongod
   
   # Install PM2 for process management
   sudo npm install -g pm2
   ```

2. **Deploy your application:**
   ```bash
   # Clone repository
   git clone https://github.com/yourusername/vehicle-system-server.git
   cd vehicle-system-server
   
   # Install dependencies
   npm install
   
   # Create .env file with production variables
   nano .env
   
   # Start with PM2
   pm2 start app.js --name vehicle-system
   pm2 startup
   pm2 save
   ```

## 🔧 Environment Variables for Production

Create a `.env` file with these variables:

```env
# Server Configuration
NODE_ENV=production
PORT=5000

# Database
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/vehicle_system

# JWT
JWT_SECRET=your_super_secure_jwt_secret_here_make_it_long_and_random

# Cloudinary (for file uploads)
CLOUD_NAME=your_cloudinary_cloud_name
CLOUD_API_KEY=your_cloudinary_api_key
CLOUD_SECRET_KEY=your_cloudinary_secret_key

# Email Configuration (for OTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SERVICE=gmail
SMTP_MAIL=your_gmail@gmail.com
SMTP_PASSWORD=your_gmail_app_password

# CORS Origins (add your frontend URLs)
FRONTEND_URL=https://your-flutter-web-app.com
ADMIN_PANEL_URL=https://your-admin-panel.com
```

## 📱 Flutter App Configuration

Update your Flutter app's API base URL:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://your-deployed-server.com/api/v1';
  
  // For development
  // static const String baseUrl = 'http://localhost:5000/api/v1';
}
```

## 🔒 Security Checklist for Production

### 1. Environment Variables
- ✅ Never commit `.env` file to git
- ✅ Use strong, unique JWT secret (min 64 characters)
- ✅ Use production MongoDB with authentication
- ✅ Use secure SMTP credentials

### 2. CORS Configuration
```javascript
// Update CORS in app.js for production
const allowedOrigins = [
  'https://your-flutter-web-app.com',
  'https://your-admin-panel.com',
  'https://your-mobile-app-domain.com'
];
```

### 3. Rate Limiting (Optional but recommended)
```bash
npm install express-rate-limit
```

```javascript
// Add to app.js
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use(limiter);
```

### 4. Helmet for Security Headers
```bash
npm install helmet
```

```javascript
// Add to app.js
import helmet from 'helmet';
app.use(helmet());
```

## 📊 MongoDB Setup

### Option 1: MongoDB Atlas (Cloud - Recommended)

1. Go to [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Create a free cluster
3. Create database user
4. Whitelist IP addresses (0.0.0.0/0 for all IPs or specific IPs)
5. Get connection string
6. Replace in MONGO_URI

### Option 2: Self-hosted MongoDB

```bash
# Ubuntu installation
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Create admin user
mongo
use admin
db.createUser({
  user: "admin",
  pwd: "strong_password",
  roles: ["userAdminAnyDatabase"]
})

# Create application database and user
use vehicle_system
db.createUser({
  user: "vehicle_user",
  pwd: "secure_password",
  roles: ["readWrite"]
})
```

## 🔍 Monitoring and Logging

### 1. PM2 Monitoring (for VPS)
```bash
# Monitor processes
pm2 monit

# View logs
pm2 logs vehicle-system

# Restart application
pm2 restart vehicle-system
```

### 2. Log Management
```javascript
// Add to app.js for better logging
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}
```

## 🧪 Testing Before Deployment

1. **Test all API endpoints:**
   ```bash
   # Install testing tools
   npm install --save-dev jest supertest
   
   # Run tests
   npm test
   ```

2. **Check environment variables:**
   ```bash
   # Create test script
   node -e "console.log(process.env.MONGO_URI ? '✅ MONGO_URI set' : '❌ MONGO_URI missing')"
   ```

3. **Test database connection:**
   ```bash
   node -e "
   import mongoose from 'mongoose';
   mongoose.connect(process.env.MONGO_URI)
     .then(() => console.log('✅ Database connected'))
     .catch(err => console.log('❌ Database error:', err));
   "
   ```

## 📱 Mobile App Deployment

### Android (Flutter)
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS (Flutter)
```bash
# Build for iOS
flutter build ios --release
```

## 🚀 CI/CD Pipeline (Optional)

### GitHub Actions Example
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm install
      
    - name: Run tests
      run: npm test
      
    - name: Deploy to Render
      # Add your deployment steps here
```

## 🐛 Troubleshooting

### Common Issues

1. **Cannot connect to MongoDB:**
   - Check MONGO_URI format
   - Verify network access in MongoDB Atlas
   - Check firewall settings

2. **CORS errors:**
   - Add your frontend URL to allowedOrigins
   - Check if requests include proper headers

3. **JWT token issues:**
   - Verify JWT_SECRET is set
   - Check token expiration time
   - Ensure consistent secret across restarts

4. **Email not sending:**
   - Verify SMTP credentials
   - Check Gmail app password (not regular password)
   - Enable "Less secure app access" if needed

### Health Check Endpoint
Add this to your app.js:
```javascript
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});
```

## 📈 Performance Optimization

1. **Database Indexing:**
   ```javascript
   // Add to your models
   userSchema.index({ email: 1 });
   vehicleSchema.index({ vehicleNumber: 1, status: 1 });
   vehicleLogSchema.index({ timestamp: -1 });
   ```

2. **Caching (Optional):**
   ```bash
   npm install redis
   ```

3. **Compression:**
   ```bash
   npm install compression
   ```
   ```javascript
   import compression from 'compression';
   app.use(compression());
   ```

## 🎯 Post-Deployment Steps

1. **Test all functionalities**
2. **Set up monitoring and alerts**
3. **Configure automatic backups**
4. **Update DNS records if using custom domain**
5. **Set up SSL certificate (usually automatic with hosting platforms)**
6. **Create admin user account**
7. **Import initial data if needed**

## 📞 Support

For deployment issues:
1. Check server logs
2. Verify environment variables
3. Test database connectivity
4. Check network/firewall settings
5. Review CORS configuration

Your Vehicle Entry & Exit System is now ready for production! 🎉