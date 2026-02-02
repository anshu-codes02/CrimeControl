const express=require("express");
const router=express.Router();
const dmService=require("../services/dmService");
const {auth}=require("../middlewares/auth");


router.get("/:userId", auth, async(req,res,next)=>{
    try{
       const user1=req.user.id;
       const user2=req.params.userId;

       const chat=await dmService.getChat(user1, user2);
       return res.status(200).json({success: true, data: chat});

    }catch(err){
        next(err);
    }
});

router.post("/send", auth, async(req, res, next)=>{
    try
    {
        const senderId=req.user.id;
        const{receiverId, content}=req.body;

        const message=await dmService.sendMessage(senderId, receiverId, content);
        res.json(message);
    }catch(err){
        next(err);
    }
});

module.exports=router;

/*
router.get("/eligible", auth, async(req, res, next)=>{
   try{
    const users=await dmService.getEligibleUsers(req.user.id);
    res.json(users);
   }catch(err){
    next(err);
   }
});

router.get("/grouped", async(req, res, next)=>{
  try{
       const grouped=await dmService.getGroupedByCase(req.user.id);
       res.status(200).json(grouped);
  }catch(err){
    next(err);
  }
});

*/