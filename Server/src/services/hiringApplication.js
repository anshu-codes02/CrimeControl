const HiringApplication = require("../models/hiring/hiringApplication");
const AppError = require("../utils/appError");
const HiringPost = require("../models/hiring/hiringPost");

exports.createHiringApplication = async (data, userId) => {

    const existingApp = await HiringApplication.findOne({ applicant: userId, post: data.post });

    if (existingApp) {
        throw new AppError("You have already applied for this hiring post", 400);
    }

    const application = await HiringApplication.create({
        ...data,
        user: userId
    });

    application.createdAt = new Date();
    application.status = "APPLIED";

    return await application.save();
}

exports.getApplicationsByPost = async (postId, userId) => {
    const post = await HiringPost.findById(postId);
    if (!post) {
        throw new AppError("Hiring post not found", 404);
    }


    if (!post.recruiter || String(post.recruiter) != String(userId)) {
        throw new AppError("Unauthorized access", 403);
    }

    const applications = await HiringApplication.find({ post: postId }).populate("applicant");

    const filteredApplications = applications.map(application => {
        return {
            id: application._id,

            postId: application.post?._id || null,

            applicantId: application.applicant?._id || null,

            coverLetter: application.coverLetter,

            createdAt: application.createdAt,

            status: application.status || null,

            applicantUsername:
                application.applicant?.username || null,

            applicantEmail:
                application.applicant?.email || null,

            applicantFirstName:
                application.applicant?.firstName || null,

            applicantLastName:
                application.applicant?.lastName || null,

            applicantRole:
                application.applicant?.role || null,
        }
    });
    return filteredApplications;
}

exports.findById = async (id) => {
    const application = await HiringApplication.findById(id).populate("applicant");
    if (!application) {
        throw new AppError("Hiring application not found", 404);
    }

    const filteredApplication={
        id: application._id,

            postId: application.post?._id || null,

            applicantId: application.applicant?._id || null,

            coverLetter: application.coverLetter,

            createdAt: application.createdAt,

            status: application.status || null,

            applicantUsername:
                application.applicant?.username || null,

            applicantEmail:
                application.applicant?.email || null,

            applicantFirstName:
                application.applicant?.firstName || null,

            applicantLastName:
                application.applicant?.lastName || null,

            applicantRole:
                application.applicant?.role || null,
    }

    return filteredApplication;
}