const User=require("../models/userModel");
const AppError = require("../utils/appError");
const HiringPost=require("../models/hiring/hiringPost");


exports.createHiringPost=async(hiringPostData, userId)=>{
   
    const recruiter=await User.findById(userId);

    if(!recruiter || recruiter.role!="RECRUITER")
    {
        throw new AppError("Only recruiters can create hiring posts", 401);
    }
    
    const newHiringPost=await HiringPost.create(hiringPostData);
    newHiringPost.recruiter=recruiter._id;
    newHiringPost.createdAt=new Date();
    newHiringPost.status="OPEN";

    await newHiringPost.save();
    return newHiringPost;
}