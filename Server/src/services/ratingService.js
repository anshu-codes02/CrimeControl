const AppError = require("../utils/appError");
const Rating = require("../models/user/userRating");
const User = require("../models/user/user");

exports.createRating=async(data)=>{
  
    
      
        if (!data.ratedUserId || !data.user?.id || !data.rating) {
      throw new AppError("Missing required fields", 400);
    }

       // Ensure rated user exists
  const user = await User.findById(data.ratedUserId);
  if (!user) {
    throw new AppError("Rated user not found", 404);
  }

      const oldRating=await Rating.findOneAndDelete({ratedUser: data.ratedUserId, rater: data.user.id});

      if (oldRating) {
    user.receivedRatings.pull(oldRating._id);
  }

        const rating = await Rating.create({
            ratedUser: data.ratedUserId,
            rater: data.user.id,
            rating: data.rating,
            comment: data.comment,
            type: data.category,
            crimeCase: data.caseId,

        });

        // Recalculate average rating
        const stats= await Rating.aggregate([
            {
                $match:{
                    ratedUser: data.ratedUserId
                },
            },
            {
                $group:{
                 _id: "$ratedUser",
                    average:{
                        $avg: "$rating"
                    },
                    count: {
                        $sum: 1
                    }
                }
            }
        ])
        user.averageRating=stats[0]?.average || 0;
        user.totalRatings=stats[0]?.count || 0;
        user.receivedRatings.push(rating._id);
        await user.save();

        return rating;
}



exports.getRatingByUserID=async(userId)=>{
    const user=await User.findById(userId);
    if(!user){
        throw new AppError("User not found", 404);
    }
    
     return await Rating.find({ ratedUser: userId })
    .sort({ createdAt: -1 })
    .populate("rater", "username email");
}


exports.canRateUser=async(raterId, ratedUserId)=>{
   const rater= await User.findById(raterId);
   if(!rater){
    return false;
   }

   if(rater.role!=="RECRUITER" || rater.role!=="ORGANIZATION"){
    return false;
   }

   return String(raterId)!==String(ratedUserId);
}


exports.deleteRating
