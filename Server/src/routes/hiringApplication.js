const express= require("express");
const router=express.Router();
const hiringApplicationService=require("../services/hiringApplicationService");
const {auth}=require("../middlewares/auth");
const hiringApplication = require("../models/hiring/hiringApplication");

//create application
router.post("/create", auth, async(req, res, next)=>{
 try{
    const application= await hiringApplicationService.createHiringApplication(req.body, req.user.id);
    res.status(200).json({success: true, message: "Hiring application created successfully", data: application});
 }catch(err){
    next(err);
 }
});

//get applications by user
router.get("/:id", auth, async(req, res, next)=>{
    try{
       const application=await hiringApplicationService.findById(req.params.id);

         res.status(200).json({success: true, data: application});
    }catch(err){
        next(err);
    }
});

//get all applications by post

router.get("/post/:id", auth, async(req, res, next)=>{
 try
 {
     const applications=await hiringApplicationService.getApplicationsByPost(req.params.id, req.user.id);
     res.status(200).json({success: true, data: applications});
 }catch(err){
    next(err);
 }
});

//delete application
router.delete("/delete/:id", auth, async(req, res, next)=>{
  try{
      await hiringApplication.findByIdAndDelete(req.params.id);

      res.status(200).json({success: true, message: "Application deleted successfully"});
  }catch(err){
      next(err);
  }
});

module.exports=router;