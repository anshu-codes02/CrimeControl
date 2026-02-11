const express = require("express");
const router = express.Router();
const dmService = require("../services/dmService");
const { auth } = require("../middlewares/auth");
const directChatMsg = require("../models/user/directChatMsg");
const mongoose = require("mongoose");


router.get("/chat/:receiverId/:caseId", auth, async (req, res, next) => {
  try {
    const user1 = req.user.id;
    const user2 = req.params.receiverId;
    const caseId = req.params.caseId;
    console.log("Fetching chat between users:", user1, user2, "for case:", caseId);
    const chat = await dmService.getChat(user1, user2, caseId);
    console.log("Fetched chat messages:", chat);

    return res.status(200).json({ success: true, data: chat });

  } catch (err) {
    next(err);
  }
});

router.post("/send", auth, async (req, res, next) => {
  try {
    const senderId = req.user.id;
    const { receiverId, content } = req.body;

    const message = await dmService.sendMessage(senderId, receiverId, content);
    res.json(message);
  } catch (err) {
    next(err);
  }
});

router.get("/grouped", auth, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user.id);
    const inbox = await directChatMsg.aggregate([
      {
        $match: {
          $or: [
            { sender: userId },
            { receiver: userId },
             { sender: userId.toString() },   // fallback
      { receiver: userId.toString() }
          ]
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
          _id: {
            caseId: "$caseId",
            peerUser: "$peerUser"
          },
          messageCount: { $sum: 1 }
        }
      },
      {
        $lookup: {
          from: "users",
          localField: "_id.peerUser",
          foreignField: "_id",
          as: "peerUserData"
        }
      },
      {
        $unwind: "$peerUserData"
      },
      {
        $lookup: {
          from: "crimecases",
          localField: "_id.caseId",
          foreignField: "_id",
          as: "caseData"
        }
      },
      {
        $unwind: "$caseData"
      },
      {
        $group: {
          _id: "$_id.caseId",
          caseTitle: { $first: "$caseData.title" },
          users: {
            $push: {
              userId: "$peerUserData._id",
              userName: "$peerUserData.username",
              firstName: "$peerUserData.firstName",
              lastName: "$peerUserData.lastName",
              displayName: {
                $concat: [
                  "$peerUserData.firstName",
                  " ",
                  "$peerUserData.lastName"
                ]
              },
              messageCount: "$messageCount",
            }
          }
        }
      },

      {
        $project: {
          _id: 0,
          caseId: "$_id",
          caseTitle: 1,
          users: 1
        }
      }
    ]);

    res.status(200).json(inbox);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


module.exports = router;