# MongoDB Duplicate Key Error Fix

## 🐛 **Problem**
Registration was failing with the error:
```
E11000 duplicate key error collection: dwaramitra.users index: universityId_1 dup key: { universityId: null }
```

## 🔍 **Root Cause Analysis**

### **The Issue**
- MongoDB had a **unique index** on `universityId` field
- Multiple users were trying to register with `universityId: null`
- **Unique indexes don't allow multiple `null` values** by default
- This caused registration failures for users without a university ID

### **Why This Happened**
1. **User Model**: Field `universityId` was defined but not required
2. **Registration**: Only `name`, `email`, `password` were being sent from frontend
3. **Default Behavior**: MongoDB sets undefined fields to `null`
4. **Index Configuration**: Original index was unique but **not sparse**

## ✅ **Solution Implemented**

### **1. Fixed User Model Schema**
```javascript
// Before (PROBLEMATIC)
universityId: {
  type: String,
  uppercase: true,
  trim: true,
},

// After (FIXED)
universityId: {
  type: String,
  uppercase: true,
  trim: true,
  sparse: true, // ✅ Allow multiple null/undefined values
},

// Index Configuration (FIXED)
userSchema.index({ universityId: 1 }, { unique: true, sparse: true });
```

### **2. Updated Registration Controller**
```javascript
// Enhanced to handle optional fields properly
const userData = {
  name,
  email,
  password: hashedPassword,
  otp,
  otpExpireAt
};

// ✅ Only add universityId if provided and not empty
if (universityId && universityId.trim()) {
  userData.universityId = universityId.trim().toUpperCase();
}
```

### **3. Database Index Migration**
Created and ran script `fix-index.js` that:
1. ✅ Connected to MongoDB
2. ✅ Dropped old non-sparse `universityId_1` index
3. ✅ Created new **sparse unique** index
4. ✅ Verified the fix

**Migration Results:**
```
Current indexes: [
  // Before
  { name: 'universityId_1', unique: true, sparse: undefined }
  
  // After  
  { name: 'universityId_1', unique: true, sparse: true }
]
```

## 🎯 **What This Fixes**

### **Immediate Benefits**
- ✅ **Registration works** for users without university ID
- ✅ **Multiple null values** allowed in universityId field
- ✅ **Uniqueness maintained** when universityId is provided
- ✅ **No duplicate key errors** during registration

### **Technical Benefits**
- ✅ **Sparse Index**: Only indexes documents where universityId exists and is not null
- ✅ **Flexible Schema**: Supports both users with and without university IDs
- ✅ **Data Integrity**: Maintains uniqueness constraint when needed
- ✅ **Backward Compatibility**: Existing users not affected

## 🧪 **Testing Results**

### **Before Fix**
```json
{
  "success": false,
  "message": "Server error during registration.",
  "error": "E11000 duplicate key error collection: dwaramitra.users index: universityId_1 dup key: { universityId: null }"
}
```

### **After Fix**
- ✅ Registration succeeds for users without universityId
- ✅ Registration succeeds for users with unique universityId
- ✅ Registration fails only for duplicate universityId (as expected)
- ✅ Server runs without errors

## 📋 **Index Configuration Details**

### **Sparse Index Behavior**
- **With sparse: false** (old): Indexes ALL documents, including those with null values
- **With sparse: true** (new): Only indexes documents where the field exists and is not null

### **Unique Constraint**
- **Still enforced** when universityId is provided
- **Allows multiple users** without universityId (null/undefined)
- **Prevents duplicates** for actual university IDs

## 🔧 **Files Modified**

1. **`models/user.model.js`**: Added `sparse: true` to field definition
2. **`controllers/auth.controller.js`**: Enhanced registration to handle optional fields
3. **`scripts/fix-index.js`**: Database migration script (one-time use)

## 🎉 **Result**

The registration system now:
- ✅ **Works for all user types** (with or without university ID)
- ✅ **Maintains data integrity** with proper uniqueness constraints
- ✅ **Supports flexible user registration** without breaking existing functionality
- ✅ **Prevents future duplicate key errors** on the universityId field

---

**Status**: ✅ **RESOLVED** - Registration now works correctly for all users!