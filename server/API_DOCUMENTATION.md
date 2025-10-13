# Vehicle Entry & Exit System API Documentation

## Base URL
```
http://localhost:PORT/api/v1
```

## Authentication
All protected routes require a JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## API Endpoints

### 🔐 Authentication Routes (`/auth`)

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@university.edu",
  "password": "password123",
  "phone": "1234567890",
  "universityId": "UNI001",
  "department": "Computer Science",
  "designation": "Student",
  "role": "user"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@university.edu",
  "password": "password123"
}
```

#### Verify OTP
```http
POST /auth/verify-otp
Authorization: Bearer <token>
Content-Type: application/json

{
  "otp": "123456"
}
```

#### Logout
```http
POST /auth/logout
Authorization: Bearer <token>
```

### 👤 User Routes (`/user`)

#### Get User Profile
```http
GET /user/profile
Authorization: Bearer <token>
```

#### Update Profile
```http
PUT /user/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Name",
  "phone": "9876543210",
  "department": "Updated Department"
}
```

### 🚗 Vehicle Routes (`/vehicles`)

#### Add Vehicle Entry
```http
POST /vehicles/add
Authorization: Bearer <token>
Content-Type: application/json

{
  "vehicleNumber": "KA01AB1234",
  "vehicleType": "two-wheeler",
  "ownerName": "John Doe",
  "ownerRole": "student",
  "universityId": "UNI001",
  "department": "Computer Science",
  "contactNumber": "1234567890",
  "gateName": "Main Gate",
  "purpose": "Class attendance"
}
```

#### Get All Vehicles
```http
GET /vehicles?page=1&limit=10&status=inside&search=KA01
Authorization: Bearer <token>
```

#### Get Vehicle by ID
```http
GET /vehicles/:id
Authorization: Bearer <token>
```

#### Update Vehicle
```http
PUT /vehicles/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "notes": "Updated notes",
  "purpose": "Updated purpose"
}
```

#### Exit Vehicle
```http
POST /vehicles/:id/exit
Authorization: Bearer <token>
```

#### Delete Vehicle Record
```http
DELETE /vehicles/:id
Authorization: Bearer <token>
```

#### Get Vehicle Statistics
```http
GET /vehicles/stats
Authorization: Bearer <token>
```

#### Get Recent Activities
```http
GET /vehicles/recent-activities?limit=10
Authorization: Bearer <token>
```

### 📊 Vehicle Logs Routes (`/vehicle-logs`)

#### Get Vehicle Logs
```http
GET /vehicle-logs?page=1&limit=20&action=entry&gateName=Main Gate
Authorization: Bearer <token>
```

#### Get Vehicle History
```http
GET /vehicle-logs/history/:vehicleNumber
Authorization: Bearer <token>
```

#### Get Activity Analytics
```http
GET /vehicle-logs/analytics?days=7
Authorization: Bearer <token>
```

### 📢 Announcements Routes (`/announcements`)

#### Get Active Announcements
```http
GET /announcements/active
Authorization: Bearer <token>
```

#### Mark Announcement as Read
```http
POST /announcements/:id/read
Authorization: Bearer <token>
```

#### Create Announcement (Admin only)
```http
POST /announcements
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "title": "Campus Maintenance",
  "message": "Main gate will be closed for maintenance from 2-4 PM",
  "type": "warning",
  "priority": "high",
  "targetAudience": ["all"],
  "expiresAt": "2024-12-31T23:59:59.000Z"
}
```

#### Get All Announcements (Admin only)
```http
GET /announcements/all?page=1&limit=10&isActive=true
Authorization: Bearer <admin_token>
```

#### Update Announcement (Admin only)
```http
PUT /announcements/:id
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "title": "Updated Title",
  "isActive": false
}
```

#### Delete Announcement (Admin only)
```http
DELETE /announcements/:id
Authorization: Bearer <admin_token>
```

### 📊 Dashboard Routes (`/dashboard`)

#### Get Dashboard Statistics (Admin/Guard only)
```http
GET /dashboard/stats
Authorization: Bearer <admin_or_guard_token>
```

#### Get Real-time Statistics
```http
GET /dashboard/realtime
Authorization: Bearer <admin_or_guard_token>
```

#### Get Security Alerts
```http
GET /dashboard/alerts
Authorization: Bearer <admin_or_guard_token>
```

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information"
}
```

## Socket.IO Events

### Client Events
- `connection` - When user connects
- `disconnect` - When user disconnects

### Server Events (Emitted to clients)
- `new-announcement` - When admin creates new announcement
- `vehicle-entry` - When vehicle enters campus
- `vehicle-exit` - When vehicle exits campus
- `security-alert` - For security notifications

## Data Models

### User Model
```javascript
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "universityId": "string",
  "department": "string",
  "designation": "Student|Staff|Faculty|Admin Staff|Visitor",
  "role": "user|guard|admin",
  "isAccountVerified": "boolean",
  "avatar": {
    "public_id": "string",
    "url": "string"
  }
}
```

### Vehicle Model
```javascript
{
  "vehicleNumber": "string",
  "vehicleType": "two-wheeler|four-wheeler|three-wheeler|bicycle|other",
  "ownerName": "string",
  "ownerRole": "student|faculty|staff|visitor",
  "universityId": "string",
  "department": "string",
  "contactNumber": "string",
  "entryTime": "Date",
  "exitTime": "Date|null",
  "gateName": "string",
  "status": "inside|exited",
  "duration": "number (minutes)",
  "purpose": "string",
  "notes": "string"
}
```

### Announcement Model
```javascript
{
  "title": "string",
  "message": "string",
  "type": "info|warning|emergency|maintenance",
  "priority": "low|medium|high|urgent",
  "targetAudience": ["all|students|faculty|staff|guards|visitors"],
  "isActive": "boolean",
  "expiresAt": "Date",
  "readBy": [
    {
      "user": "ObjectId",
      "readAt": "Date"
    }
  ]
}
```

## Flutter Integration Example

```dart
// API Service Class
class VehicleApiService {
  static const String baseUrl = 'http://your-server-url/api/v1';
  
  // Add vehicle entry
  Future<ApiResponse> addVehicleEntry(VehicleEntry entry) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonEncode(entry.toJson()),
    );
    
    return ApiResponse.fromJson(jsonDecode(response.body));
  }
  
  // Get vehicles with filters
  Future<VehicleListResponse> getVehicles({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    var queryParams = '?page=$page&limit=$limit';
    if (status != null) queryParams += '&status=$status';
    if (search != null) queryParams += '&search=$search';
    
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles$queryParams'),
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    
    return VehicleListResponse.fromJson(jsonDecode(response.body));
  }
}
```

## Security Features

1. **JWT Authentication** - Secure token-based authentication
2. **Role-based Access Control** - Different permissions for users, guards, and admins
3. **Input Validation** - Server-side validation for all inputs
4. **Rate Limiting** - Prevent API abuse (can be implemented)
5. **CORS Protection** - Configured allowed origins
6. **Password Hashing** - BCrypt for secure password storage
7. **OTP Verification** - Email-based account verification

## Development Setup

1. Install dependencies: `npm install`
2. Set up environment variables in `.env`
3. Start MongoDB server
4. Run development server: `npm run dev`
5. Access API at `http://localhost:PORT/api/v1`

## Environment Variables Required

```env
NODE_ENV=development
PORT=5000
MONGO_URI=mongodb://localhost:27017/vehicle_system
JWT_SECRET=your_jwt_secret_here
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