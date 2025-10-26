// Database migration script to fix universityId index issue
// Run this script to drop and recreate the universityId index as sparse

import mongoose from 'mongoose';
import User from '../models/user.model.js';

async function fixUniversityIdIndex() {
  try {
    console.log('🔄 Starting universityId index migration...');
    
    // Connect to MongoDB (make sure your connection string is correct)
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dwaramitra');
    console.log('✅ Connected to MongoDB');
    
    // Check existing indexes
    const indexes = await User.collection.getIndexes();
    console.log('📋 Current indexes:', Object.keys(indexes));
    
    // Drop the existing universityId index if it exists
    try {
      await User.collection.dropIndex('universityId_1');
      console.log('🗑️ Dropped existing universityId_1 index');
    } catch (error) {
      if (error.code === 27) {
        console.log('ℹ️ universityId_1 index does not exist, continuing...');
      } else {
        console.error('❌ Error dropping index:', error.message);
        throw error;
      }
    }
    
    // Create new sparse unique index
    await User.collection.createIndex(
      { universityId: 1 }, 
      { 
        unique: true, 
        sparse: true,
        name: 'universityId_1_sparse'
      }
    );
    console.log('✅ Created new sparse unique index for universityId');
    
    // Verify the new index
    const newIndexes = await User.collection.getIndexes();
    console.log('📋 Updated indexes:', Object.keys(newIndexes));
    
    // Check if the new index is sparse
    const universityIdIndex = newIndexes['universityId_1_sparse'];
    if (universityIdIndex && universityIdIndex.sparse) {
      console.log('✅ Index is properly configured as sparse');
    } else {
      console.log('⚠️ Index may not be sparse, check configuration');
    }
    
    console.log('🎉 Migration completed successfully!');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Alternative: Drop all users with null universityId and recreate index
async function cleanupAndRecreateIndex() {
  try {
    console.log('🔄 Starting cleanup and index recreation...');
    
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dwaramitra');
    console.log('✅ Connected to MongoDB');
    
    // Count users with null universityId
    const nullUniversityIdCount = await User.countDocuments({ 
      $or: [
        { universityId: null },
        { universityId: { $exists: false } }
      ]
    });
    console.log(`📊 Found ${nullUniversityIdCount} users with null/missing universityId`);
    
    // Option 1: Set universityId to undefined for users where it's null
    const updateResult = await User.updateMany(
      { universityId: null },
      { $unset: { universityId: "" } }
    );
    console.log(`🔄 Updated ${updateResult.modifiedCount} users to remove null universityId`);
    
    // Drop and recreate index
    try {
      await User.collection.dropIndex('universityId_1');
      console.log('🗑️ Dropped existing universityId_1 index');
    } catch (error) {
      console.log('ℹ️ universityId_1 index may not exist');
    }
    
    await User.collection.createIndex(
      { universityId: 1 }, 
      { unique: true, sparse: true }
    );
    console.log('✅ Created new sparse unique index');
    
    console.log('🎉 Cleanup completed successfully!');
    
  } catch (error) {
    console.error('❌ Cleanup failed:', error);
  } finally {
    await mongoose.disconnect();
  }
}

// Run migration
if (process.argv[2] === 'cleanup') {
  cleanupAndRecreateIndex();
} else {
  fixUniversityIdIndex();
}
