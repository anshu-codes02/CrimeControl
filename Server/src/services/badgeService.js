const User=require("../models/userModel");
const BadgeAward=require("../models/badgeAward");
const userService=require("./userService");
const AppError = require("../utils/appError");
const Badge=require("../models/badge");


exports.getBadgeByUserId=async(userId)=>{
    const user=await User.findById(userId);
    if(!user){
        throw new AppError("User not found", 404);
    }

    const badges=await BadgeAward.find({userId: userId}).populate("badgeId");
    return badges;
}

exports.awardBadgeToUser=async(data)=>{
  const {user, badge, reason, crimeCase, awardedBy}=data;

  const award= await BadgeAward.create({
    user: user,
    badge: badge,
    reason: reason,
    crimeCase: crimeCase,
    awardedBy: awardedBy,
    awardedAt: new Date()
  });

    award=await award.save();
    await userService.addBadge(user, badge.name);
    return award;
}

exports.canAwardBadge=async(data, awarderId)=>{
  
    const user=await User.findById(awarderId);
    if(!user || user.role!="SOLVER"){
       return false;
    }

    const badge=await Badge.findById(data.badgeId);

    if(badge.requiredCases && user.solvedCasesCount < badge.requiredCases){
      return false;   
    }

    if(badge.requiredRating && user.averageRating && user.averageRating < badge.requiredRating){
      return false;   
    }

    const exists=await BadgeAward.findOne({user: awarderId, badgeId: data.badgeId});

    if(exists){
        return false;
    }
    
    return true;
}