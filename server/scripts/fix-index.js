import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

async function fixIndex() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dwaramitra';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');
    
    const db = mongoose.connection.db;
    const collection = db.collection('users');
    
    // Check existing indexes
    const indexes = await collection.indexes();
    console.log('Current indexes:', indexes.map(idx => ({ name: idx.name, key: idx.key, unique: idx.unique, sparse: idx.sparse })));
    
    // Drop the problematic index
    try {
      await collection.dropIndex('universityId_1');
      console.log('✅ Dropped universityId_1 index');
    } catch (error) {
      console.log('⚠️ universityId_1 index may not exist:', error.message);
    }
    
    // Create new sparse unique index
    await collection.createIndex(
      { universityId: 1 }, 
      { 
        unique: true, 
        sparse: true,
        background: true
      }
    );
    console.log('✅ Created new sparse unique index for universityId');
    
    const newIndexes = await collection.indexes();
    const universityIdIndex = newIndexes.find(idx => idx.key.universityId);
    
    if (universityIdIndex) {
      console.log('📋 New universityId index:', {
        name: universityIdIndex.name,
        unique: universityIdIndex.unique,
        sparse: universityIdIndex.sparse
      });
    }
    
    console.log('🎉 Index fix completed successfully!');
    
  } catch (error) {
    console.error('❌ Error fixing index:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the fix
fixIndex();