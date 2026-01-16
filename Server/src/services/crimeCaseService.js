const crimeCase=require("../models/case/crimeCase");
const CaseComment=require("../models/case/caseComment");
const crimeCase = require("../models/case/crimeCase");

exports.createCase=async(crimeCase, postedBy)=>{

    crimeCase.postedBy=postedBy;
    crimeCase.status="OPEN";
    crimeCase.postedAt= new Date();
    crimeCase.updatedAt= new Date();

    const savedCase= await crimeCase.create(crimeCase);
    return savedCase;
}

exports.updateCase=async(caseId, crimeCase)=>{
    crimeCase.updatedAt= new Date();
    return crimeCase.findByIdAndUpdate(caseId, crimeCase, {new:true});
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
   const crimeCase= await crimeCase.findById(caseId);
   if(!crimeCase){
    throw new Error("Case not found");
   }
   crimeCase.status="CLOSED";
   crimeCase.closedAt=new Date();
   crimeCase.updatedAt=new Date();
   return crimeCase.save();   
}

exports.deleteCase=async(caseId, userId)=>{
    const crimeCase= await crimeCase.findById(caseId);
   if(!crimeCase){
    throw new Error("Case not found");
   }
    
  crimeCase.findByIdAndDelete(caseId);
}