const express=require("express");
const router=express.Router();
const hiringChatService=require("../services/hiringChatMsg");


router.post("/", async(req, res, next)=>{
   try{
       const msg = await hiringChatService.sendMessage({
      applicationId: req.body.applicationId,
      senderId: req.user.id,
      message: req.body.message
    });

    res.status(201).json(msg);
   }catch(err){
    next(err);
   }
});

module.exports=router;