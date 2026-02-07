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
    const newComment =await CaseComment.create({
        content: comment,
        crimeCase: caseId,
        user: userId
    });

    await CrimeCase.findByIdAndUpdate(
    caseId,
    { $push: { comments: newComment._id } },
    { new: true }
  );

}

//to close case
exports.closeCase=async(caseId, userId)=>{
    console.log("Closing case", caseId, "by user", userId);
   const crimeCase= await CrimeCase.findById(caseId);
   if(!crimeCase){
    throw new AppError("Case not found", 404);
   }
   crimeCase.status="CLOSED";
   crimeCase.closedAt=new Date();
   crimeCase.updatedAt=new Date();
   return await crimeCase.save();   
}

exports.deleteCase=async(caseId, userId)=>{
    const crimeCase= await CrimeCase.findById(caseId);
   if(!crimeCase){
    throw new AppError("Case not found", 404);
   }
    
  crimeCase.findByIdAndDelete(caseId);
}

exports.canDeleteCase = async (caseId) => {
  const crimeCase = await CrimeCase.findById(caseId);

  if (!crimeCase) {
    throw new AppError("Case not found", 404);
  }

  const isClosed = crimeCase.status === "CLOSED";

  let deletableAt = null;
  let hoursUntilDeletable = null;
  let canDelete = false;

  if (isClosed && crimeCase.closedAt) {
    const closedAt = new Date(crimeCase.closedAt);
    deletableAt = new Date(closedAt.getTime() + 24 * 60 * 60 * 1000);

    const now = new Date();
    hoursUntilDeletable = Math.max(
      0,
      Math.ceil((deletableAt - now) / (60 * 60 * 1000))
    );

    canDelete = now >= deletableAt;
  }

  // ✅ return a plain object (map)
  return {
    canDelete,
    isClosed,
    closedAt: crimeCase.closedAt,
    deletableAt,
    hoursUntilDeletable,
  };
};
