const User=require("../models/user/user");
const DirectMessage=require("../models/user/directChatMsg");
const AppError=require("../utils/appError");
const mongoose=require("mongoose");

exports.sendMessage = async (senderId, receiverId, caseId, content) => {
  if (!content || !content.trim()) {
    throw new AppError("Message content is required", 400);
  }

  const [sender, receiver] = await Promise.all([
    User.findById(senderId),
    User.findById(receiverId)
  ]);

  if (!sender || !receiver) {
    throw new AppError("Invalid sender or receiver", 400);
  }

  const val= await DirectMessage.create({
    sender: senderId,
    receiver: receiverId,
    content,
    caseId
  });
  console.log("Message created:", val);
  return val;
};

exports.getChat = async (user1id, user2id, caseId) => {
  const u1 = new mongoose.Types.ObjectId(user1id);
  const u2 = new mongoose.Types.ObjectId(user2id);
  const cId = new mongoose.Types.ObjectId(caseId);

  return await DirectMessage.find({
    caseId: cId,
    $or: [
      { sender: u1, receiver: u2 },
      { sender: u2, receiver: u1 }
    ]
  })
    .sort({ sentAt: 1 })
    .populate("sender", "username")
    .populate("receiver", "username");
};
































/*
 * 3️⃣ Get eligible DM users
 * Users who commented on same cases

exports.getEligibleUsers = async (currentUserId) => {
  const userComments = await CaseComment.find({
    user: currentUserId
  }).select("crimeCase");

  const caseIds = [
    ...new Set(userComments.map(c => c.crimeCase.toString()))
  ];

  if (!caseIds.length) return [];

  const allComments = await CaseComment.find({
    crimeCase: { $in: caseIds }
  }).populate("user", "username");

  const eligibleUsersMap = new Map();

  for (const comment of allComments) {
    if (comment.user._id.toString() !== currentUserId.toString()) {
      eligibleUsersMap.set(
        comment.user._id.toString(),
        comment.user
      );
    }
  }

  return Array.from(eligibleUsersMap.values());
};


 * 4️⃣ Group DMs by Case
 * Case → Users → Messages
 
exports.getGroupedByCase = async (currentUserId) => {
  const userComments = await CaseComment.find({
    user: currentUserId
  }).populate("crimeCase", "title");

  const caseIds = [
    ...new Set(userComments.map(c => c.crimeCase._id.toString()))
  ];

  if (!caseIds.length) return [];

  const allComments = await CaseComment.find({
    crimeCase: { $in: caseIds }
  })
    .populate("crimeCase", "title")
    .populate("user", "username");

  const caseMap = {};

  for (const comment of allComments) {
    const caseId = comment.crimeCase._id.toString();

    if (!caseMap[caseId]) {
      caseMap[caseId] = {
        caseId,
        caseTitle: comment.crimeCase.title,
        users: new Map()
      };
    }

    if (comment.user._id.toString() !== currentUserId.toString()) {
      caseMap[caseId].users.set(
        comment.user._id.toString(),
        comment.user
      );
    }
  }

  const result = [];

  for (const caseId in caseMap) {
    const users = [];

    for (const user of caseMap[caseId].users.values()) {
      const messages = await DirectMessage.find({
        $or: [
          { sender: currentUserId, receiver: user._id },
          { sender: user._id, receiver: currentUserId }
        ]
      }).sort({ createdAt: 1 });

      users.push({
        userId: user._id,
        userName: user.username,
        messages
      });
    }

    result.push({
      caseId,
      caseTitle: caseMap[caseId].caseTitle,
      users
    });
  }

  return result;
};
*/