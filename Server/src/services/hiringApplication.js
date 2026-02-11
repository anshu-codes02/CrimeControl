const HiringApplication = require("../models/hiring/hiringApplication");
const AppError = require("../utils/appError");
const HiringPost = require("../models/hiring/hiringPost");

exports.createHiringApplication = async (data, userId) => {

    const existingApp = await HiringApplication.findOne({ applicantId: userId, postId: data.postId });

    if (existingApp) {
        throw new AppError("You have already applied for this hiring post", 400);
    }

    const application = await HiringApplication.create({
        postId: data.postId,
        applicantId: userId,
        coverLetter: data.coverLetter
    });

    application.createdAt = new Date();
    application.status = "APPLIED";

    return  application;
}

exports.getApplicationsByPost = async (postId, userId) => {
    const post = await HiringPost.findById(postId);
    if (!post) {
        throw new AppError("Hiring post not found", 404);
    }


    if (!post.recruiter || String(post.recruiter) != String(userId)) {
        throw new AppError("Unauthorized access", 403);
    }

    const applications = await HiringApplication.find({ postId: postId }).populate("applicantId");

    const filteredApplications = applications.map(application => {
        return {
            id: application._id,

            postId: application.postId || null,
            title: post.caseType || null,

            applicantId: application.applicantId?._id || null,

            coverLetter: application.coverLetter,

            createdAt: application.createdAt,

            status: application.status || null,

            applicantUsername:
                application.applicantId?.username || null,

            applicantEmail:
                application.applicantId?.email || null,

            applicantFirstName:
                application.applicantId?.firstName || null,

            applicantLastName:
                application.applicantId?.lastName || null,

            applicantRole:
                application.applicantId?.role || null,
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