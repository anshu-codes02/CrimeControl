const express= require("express");
const router= express.Router();
const badgeService=require("../services/badgeService");
const Badge = require("../models/badge");
const {auth, isAdmin}=require("../middlewares/auth");

router.post('/create', auth, isAdmin, async(req, res, next)=>{
  try
  {
     const badge=await Badge.create(req.body);
     badge.createdAt=new Date();
     badge.updatedAt=new Date();
     await badge.save();
     
     res.status(200).json({success: true, message: "Badge created successfully"});
  }catch(err){
    next(err);
  }
});

//get all badges
router.get('/', auth, isAdmin, async(req, res, next)=>{
  try{
      const badges= await Badge.find();
      res.status(200).json({success: true, data: badges});
  }catch(err){
    next(err);
  }
});

//get badge by id
router.post('/:id', auth, isAdmin, async(req, res, next)=>{
  try{
     const badge= await Badge.findById(req.params.id);

     if(!badge){
        return  res.status(404).json({success: false, message: "Badge not found"});
     }

        res.status(200).json({success: true, data: badge});
  }catch(err){
    next(err);
  }
});

//update badge
router.put('/update/:id', auth, isAdmin, async(req, res, next)=>{
  try{
      const badge= await Badge.findByIdAndUpdate(req.params.id, req.body, {new: true});

      if(!badge){
        return res.status(404).json({success: false, message: "Badge not found"});
      } 

        res.status(200).json({success: true, message: "Badge updated successfully"});

  }catch(err){
    next(err);
  }
});

//delete badge
router.delete('/delete/:id', auth, isAdmin, async(req, res, next)=>{
  try{
      await Badge.findByIdAndDelete(req.params.id); 
        res.status(200).json({success: true, message: "Badge deleted successfully"});
  }catch(err){
    next(err);
  }
});


// get userBadges
router.get('/user/:userId', auth, async(req, res, next)=>{
  try{
       
      const badges= await badgeService.getUserBadges(req.params.userId);
      res.status(200).json({success: true, data: badges});
  }catch(err){
    next(err);
  }
});

router.post('/award', async(req, res, next)=>{
   try{
      await badgeService.awardBadgeToUser(req.body);
      res.status(200).json({success: true, message: "Badge awarded successfully"});
   }catch(err){
    next(err);
   }
});

//permission check
 
router.post('/check/:idToAward', auth, async(req, res, next)=>{
  try{
      const can= await badgeService.canAwardBadges(req.body, req.params.idToAward);
        res.status(200).json({success: can, message: can ? "User can award badges" : "only recruiters and organizations can award"});
  }catch(err){
    next(err);
  }
});

module.exports=router;
