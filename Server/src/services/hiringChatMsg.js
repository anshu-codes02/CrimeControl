const HiringApplication=require("../models/hiring/hiringApplication");
const HiringChatMessage=require("../models/hiring/hiringChatMsg");
const AppError=require("../utils/appError");


exports.sendMessage = async ({ applicationId, senderId, message }) => {
  const application = await HiringApplication.findById(applicationId);
  if (!application) {
    throw new AppError("Application not found", 404);
  }

  if (![application.recruiter, application.applicant]
        .includes(senderId)) {
    throw new AppError("Unauthorized", 403);
  }

  return HiringChatMessage.create({
    application: applicationId,
    sender: senderId,
    message,
    timestamp: new Date()
  });
};
