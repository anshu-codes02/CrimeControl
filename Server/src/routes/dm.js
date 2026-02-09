const express=require("express");
const router=express.Router();
const dmService=require("../services/dmService");
const {auth}=require("../middlewares/auth");


router.get("/chat/:receiverId/:caseId", auth, async(req,res,next)=>{
    try{
       const user1=req.user.id;
       const user2=req.params.receiverId;
       const caseId=req.params.caseId;
       console.log("Fetching chat between users:", user1, user2, "for case:", caseId);
       const chat=await dmService.getChat(user1, user2, caseId);
       console.log("Fetched chat messages:", chat);

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

router.get("/dm/grouped", auth, async (req, res) => {
  try {
    const userId = req.user._id;

    const inbox = await DirectMessage.aggregate([
      {
        $match: {
          $or: [{ sender: userId }, { receiver: userId }]
        }
      },
      {
        $addFields: {
          peerUser: {
            $cond: [
              { $eq: ["$sender", userId] },
              "$receiver",
              "$sender"
            ]
          }
        }
      },
      {
        $group: {
          _id: { caseId: "$caseId", peerUser: "$peerUser" },
          messages: { $push: "$$ROOT" }
        }
      },
      {
        $group: {
          _id: "$_id.caseId",
          users: {
            $push: {
              userId: "$_id.peerUser",
              messages: "$messages"
            }
          }
        }
      },
      {
        $lookup: {
          from: "crimecases",
          localField: "_id",
          foreignField: "_id",
          as: "case"
        }
      },
      {
        $lookup: {
          from: "users",
          localField: "users.userId",
          foreignField: "_id",
          as: "userDetails"
        }
      },
      {
        $project: {
          caseId: "$_id",
          caseTitle: { $arrayElemAt: ["$case.title", 0] },
          users: 1
        }
      }
    ]);

    res.json(inbox);
  } catch (err) {
    res.status(500).json({ error: err.message });
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