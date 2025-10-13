import mongoose from "mongoose";
import { MONGO_URI,NODE_ENV } from "../config/env.js";

const connecttoDatabase = async ()=>{
    try{
        await mongoose.connect(MONGO_URI);
        console.log(`MONGODB connection is Successful and in ${NODE_ENV} mode`);
    }catch(error){
        console.error('Error connecting to database: ',error);
        console.error('Please check your MongoDB URI and ensure the database server is running.');
        console.error('Exiting the application...');
        process.exit(1);
    }
}

export default connecttoDatabase;