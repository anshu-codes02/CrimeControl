const crimeCase=require("../models/case/crimeCase");
const CaseComment=require("../models/case/caseComment");
const CrimeCase = require("../models/case/crimeCase");
const AppError= require("../utils/appError");

exports.createCase=async(crimeCase, postedBy)=>{

    crimeCase.postedBy=postedBy;
    crimeCase.status="OPEN";
    crimeCase.postedAt= new Date();
    crimeCase.updatedAt= new Date();

    const savedCase= await CrimeCase.create(crimeCase);
    return savedCase;
}

exports.updateCase=async(caseId, crimeCase)=>{
    crimeCase.updatedAt= new Date();
    return CrimeCase.findByIdAndUpdate(caseId, crimeCase, {new:true});
}

//to add comment
exports.addComment=async(caseId,userId, comment)=>{
    await CaseComment.create({
        content: comment,
        crimeCase: caseId,
        user: userId
    });
}

//to close case
exports.closeCase=async(caseId, userId)=>{
   const crimeCase= await CrimeCase.findById(caseId);
   if(!crimeCase){
    throw new AppError("Case not found", 404);
   }
   crimeCase.status="CLOSED";
   crimeCase.closedAt=new Date();
   crimeCase.updatedAt=new Date();
   return CrimeCase.save();   
}

exports.deleteCase=async(caseId, userId)=>{
    const crimeCase= await CrimeCase.findById(caseId);
   if(!crimeCase){
    throw new AppError("Case not found", 404);
   }
    
  crimeCase.findByIdAndDelete(caseId);
}