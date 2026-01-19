const express= require("express");
const router=express.Router();
const ratingService=require("../services/ratingService");
const {auth}=require("../middlewares/auth");


//rate
router.post('/create', auth, async(req, res, next)=>{
  try{
       await ratingService.createRating(req.body);
         res.status(200).json({success: true, message: "Rated successfully"});
  }catch(err){
    next(err);
  }
});

//get rating

router.get('/:userId', auth, async(req, res, next)=>{
 try{
    const ratings= await ratingService.getRatingsByUserId(req.params.userId);
    res.status(200).json({success: true, data: ratings});
 }catch(err){
    next(err);
 }
});

// delete rating
router.post('/delete/:ratingId', auth, async(req, res, next)=>{
  try{
    await ratingService.deleteRating(req.user.id, req.params.ratingId);
    res.status(200).json({success: true, message: "Rating deleted successfully"});
  }catch(err){
    next(err);
  }
});

//can Rate
router.post('/check/:userId', auth, async(req, res, next)=>{
   try{
    const canRate= await ratingService.canRateUser(req.user.id, req.params.userId);
    res.status(200).json({success: canRate});
   }catch(err){
    next(err);
   }
});

module.exports=router;