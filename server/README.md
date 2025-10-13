# 🚗 Vehicle Entry & Exit System - Sunrise University

A comprehensive Node.js backend system for managing vehicle entry and exit at university campuses with real-time tracking, analytics, and mobile app integration.

## 🌟 Features

### Core Functionality
- ✅ **User Management** - Students, staff, faculty, guards, and admins
- ✅ **Vehicle Registration** - Register multiple vehicles per user
- ✅ **Entry/Exit Tracking** - Real-time vehicle movement logging
- ✅ **QR Code Integration** - Generate and verify QR codes for quick access
- ✅ **Role-based Access Control** - Different permissions for different user types
- ✅ **JWT Authentication** - Secure token-based authentication with OTP verification

### Advanced Features
- 📊 **Analytics Dashboard** - Comprehensive statistics and insights
- 📢 **Announcements System** - Campus-wide notifications with targeting
- 📱 **Mobile App Support** - RESTful APIs for Flutter integration
- 🔍 **Activity Logging** - Detailed audit trails for all operations
- ⚡ **Real-time Updates** - Socket.IO for live notifications
- 🔒 **Security Alerts** - Suspicious activity detection and long-stay alerts

### Technical Features
- 🌐 **RESTful APIs** - Well-documented endpoints for all operations
- 📊 **Data Analytics** - Peak hours, department-wise stats, trends analysis
- 🔄 **Real-time Communication** - Socket.IO for instant updates
- 📁 **File Upload Support** - Cloudinary integration for documents/images
- 📧 **Email Integration** - Nodemailer for OTP and notifications
- 🗄️ **MongoDB Integration** - Scalable NoSQL database with proper indexing

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Admin Panel   │    │   Guard App     │
│   (Students/    │    │   (Web-based)   │    │   (Mobile)      │
│    Staff)       │    │                 │    │                 │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴───────────────┐
                    │     Node.js Server         │
                    │  (Express.js + Socket.IO)  │
                    └─────────────┬───────────────┘
                                 │
                    ┌─────────────┴───────────────┐
                    │      MongoDB Database      │
                    │    (User, Vehicle, Logs)   │
                    └─────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v16+)
- MongoDB (v4.4+)
- npm or yarn

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/vehicle-system-server.git
   cd vehicle-system-server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start MongoDB:**
   ```bash
   # Windows
   net start MongoDB
   
   # macOS/Linux
   sudo systemctl start mongod
   ```

5. **Run the application:**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

6. **Access the API:**
   ```
   http://localhost:5000/api/v1
   ```

## 📁 Project Structure

```
vehicle-system-server/
├── 📁 config/
│   ├── env.js                 # Environment configuration
│   └── nodemailer.js          # Email configuration
├── 📁 controllers/
│   ├── auth.controller.js     # Authentication logic
│   ├── user.controller.js     # User management
│   ├── vehicle.controller.js  # Vehicle operations
│   ├── vehicleLog.controller.js # Activity logging
│   ├── announcement.controller.js # Announcements
│   └── dashboard.controller.js # Analytics & dashboard
├── 📁 database/
│   └── mongodb.js            # Database connection
├── 📁 middleware/
│   ├── catchAsyncErrors.js   # Error handling
│   └── isAuthenticated.js    # Authentication middleware
├── 📁 models/
│   ├── user.model.js         # User schema
│   ├── vehicle.model.js      # Vehicle schema
│   ├── vehicleLog.model.js   # Activity log schema
│   └── announcement.model.js # Announcement schema
├── 📁 routes/
│   ├── auth.route.js         # Authentication routes
│   ├── user.route.js         # User routes
│   ├── vehicle.route.js      # Vehicle routes
│   ├── vehicleLog.route.js   # Log routes
│   ├── announcement.route.js # Announcement routes
│   └── dashboard.route.js    # Dashboard routes
├── 📁 services/
│   ├── auth.services.js      # Authentication services
│   ├── otp.services.js       # OTP generation/verification
│   └── user.services.js      # User-related services
├── 📁 utils/
│   ├── ErrorHandler.js       # Custom error handling
│   ├── jwt.js               # JWT utilities
│   ├── QRCodeGenerator.js    # QR code generation
│   └── Analytics.generator.js # Analytics utilities
├── 📁 mails/
│   └── *.ejs                # Email templates
├── app.js                   # Main application file
├── package.json
├── API_DOCUMENTATION.md     # Complete API docs
├── DEPLOYMENT_GUIDE.md      # Production deployment guide
└── README.md               # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Server Configuration
NODE_ENV=development
PORT=5000

# Database
MONGO_URI=mongodb://localhost:27017/vehicle_system

# JWT
JWT_SECRET=your_jwt_secret_here

# Cloudinary (for file uploads)
CLOUD_NAME=your_cloudinary_name
CLOUD_API_KEY=your_cloudinary_api_key
CLOUD_SECRET_KEY=your_cloudinary_secret

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SERVICE=gmail
SMTP_MAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

## 📊 API Documentation

### Main Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/v1/auth/register` | Register new user | ❌ |
| POST | `/api/v1/auth/login` | User login | ❌ |
| POST | `/api/v1/vehicles/add` | Add vehicle entry | ✅ |
| GET | `/api/v1/vehicles` | Get all vehicles | ✅ |
| POST | `/api/v1/vehicles/:id/exit` | Exit vehicle | ✅ |
| GET | `/api/v1/dashboard/stats` | Dashboard statistics | ✅ (Admin/Guard) |
| GET | `/api/v1/announcements/active` | Get active announcements | ✅ |

[📖 **Complete API Documentation**](./API_DOCUMENTATION.md)

## 🎯 Use Cases

### For Students/Staff
- Register and verify account
- Register personal vehicles
- View vehicle history
- Receive campus announcements

### For Guards
- Scan QR codes for quick entry/exit
- View real-time vehicle status
- Access security alerts
- Log vehicle activities

### For Admins
- Comprehensive dashboard with analytics
- User and vehicle management
- Create campus announcements
- Monitor security alerts
- Generate reports

## 🔒 Security Features

- **JWT Authentication** with secure token management
- **Role-based Access Control** (User, Guard, Admin)
- **Input Validation** with Mongoose schemas
- **Password Hashing** using bcryptjs
- **CORS Protection** with configurable origins
- **Rate Limiting** capabilities (configurable)
- **Audit Logging** for all critical operations

## 📱 Mobile App Integration

This backend is designed to work seamlessly with Flutter mobile applications:

```dart
// Example Flutter API call
class VehicleService {
  static Future<Map<String, dynamic>> addVehicleEntry(VehicleEntry entry) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/vehicles/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonEncode(entry.toJson()),
    );
    
    return jsonDecode(response.body);
  }
}
```

## 📊 Analytics & Reporting

The system provides comprehensive analytics:

- **Real-time Statistics** - Current vehicles inside campus
- **Peak Hours Analysis** - Busiest times of the day
- **Department-wise Stats** - Vehicle distribution by department
- **Gate Activity** - Entry/exit patterns by gate
- **Duration Analysis** - Average parking duration
- **Security Alerts** - Long-stay vehicles and suspicious activity

## 🚀 Deployment

### Quick Deploy Options

1. **Render** (Recommended)
   ```bash
   # Connect GitHub repo to Render
   # Set build command: npm install
   # Set start command: npm start
   ```

2. **Railway**
   ```bash
   npm install -g @railway/cli
   railway login
   railway init
   railway up
   ```

3. **Heroku**
   ```bash
   heroku create your-app-name
   git push heroku main
   ```

[📖 **Complete Deployment Guide**](./DEPLOYMENT_GUIDE.md)

## 🧪 Testing

```bash
# Run all tests
npm test

# Run specific test suite
npm test -- --grep "Vehicle Controller"

# Test with coverage
npm run test:coverage
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Documentation**: Check API_DOCUMENTATION.md for detailed API info
- **Deployment**: See DEPLOYMENT_GUIDE.md for production setup
- **Issues**: Create an issue on GitHub for bug reports
- **Discussions**: Use GitHub Discussions for questions

## 🎯 Roadmap

### Phase 1 (Current)
- ✅ Core vehicle entry/exit system
- ✅ User authentication and authorization
- ✅ Basic analytics dashboard
- ✅ Mobile API integration

### Phase 2 (Next)
- 🔄 AI-powered number plate recognition
- 🔄 Advanced reporting and exports
- 🔄 Push notifications
- 🔄 Visitor management system

### Phase 3 (Future)
- 🔄 Integration with university ERP
- 🔄 Automated gate systems
- 🔄 Parking fee management
- 🔄 Mobile app for iOS/Android

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Express.js team for the excellent web framework
- MongoDB team for the flexible database solution
- Socket.IO for real-time communication capabilities
- The open-source community for various packages used

---

**Made with ❤️ for Sunrise University**

*Simplifying campus vehicle management, one entry at a time.*