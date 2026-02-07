const AppError = require("../utils/appError");
const Rating = require("../models/user/userRating");
const User = require("../models/user/user");
const mongoose = require("mongoose");

exports.createRating = async (data, raterId) => {

   console.log("Creating rating with data:", data);
    if (!data.ratedUserId || !raterId || !data.rating) {
        throw new AppError("Missing required fields", 400);
    }

    // Ensure rated user exists
    const user = await User.findById(data.ratedUserId);
    if (!user) {
        throw new AppError("Rated user not found", 404);
    }

    const oldRating = await Rating.findOneAndDelete({ ratedUser: data.ratedUserId, rater: raterId });

    if (oldRating) {
        user.receivedRatings.pull(oldRating._id);
    }

    const rating = await Rating.create({
        ratedUser: data.ratedUserId,
        rater: raterId,
        rating: data.rating,
        comment: data.comment,
        type: data.category,
        crimeCase: data.caseId,

    });

    // Recalculate average rating
    const stats = await Rating.aggregate([
        {
            $match: {
                ratedUser: new mongoose.Types.ObjectId(data.ratedUserId),
            },
        },
        {
            $group: {
                _id: "$ratedUser",
                average: {
                    $avg: "$rating"
                },
                count: {
                    $sum: 1
                }
            }
        }
    ])
    user.averageRating = stats[0]?.average || 0;
    user.totalRatings = stats[0]?.count || 0;
    user.receivedRatings.push(rating._id);
    console.log("Updated user rating stats:", {
        averageRating: user.averageRating,
        totalRatings: user.totalRatings
    });
    await user.save();

    return rating;
}



exports.getRatingByUserID = async (userId) => {
    const user = await User.findById(userId);
    if (!user) {
        throw new AppError("User not found", 404);
    }

    return await Rating.find({ ratedUser: userId })
        .sort({ createdAt: -1 })
        .populate("rater", "username email");
}


exports.canRateUser = async (raterId, ratedUserId) => {
    const rater = await User.findById(raterId);
    if (!rater) {
        return false;
    }

    if (rater.role !== "RECRUITER" || rater.role !== "ORGANIZATION") {
        return false;
    }

    return String(raterId) !== String(ratedUserId);
}


exports.deleteRating = async (userId, ratingId) => {

    const session = await Rating.startSession();
    session.startTransaction();

    try {

        const rating = await Rating.findById(ratingId).session(session);
        if (!rating) throw new AppError("Rating not found", 404);

        const rater = await User.findById(userId).session(session);

        if (!rating.rater.equals(userId) || !rater || (rater.role !== "RECRUITER" && rater.role !== "ORGANIZATION")) {
            throw new AppError("Unauthorized to delete this rating", 403);
        }

        await Rating.findByIdAndDelete(ratingId, { session });

        const user = await User.findById(rating.ratedUser);
        if (!user) throw new AppError("Rated user not found", 404);

        const stats = await Rating.aggregate([
            { $match: { ratedUser:  new mongoose.Types.ObjectId(user._id), } },
            {
                $group: {
                    _id: "$ratedUser",
                    average: { $avg: "$rating" },
                    count: { $sum: 1 }
                }
            }
        ]).session(session);

        user.averageRating = Number(stats[0]?.average || 0);
        user.totalRatings = stats[0]?.count || 0;
        user.receivedRatings.pull(ratingId);

        await user.save({ session });

        await session.commitTransaction();

    } catch (err) {
        await session.abortTransaction();
        throw err;
    } finally {
        session.endSession();
    }

};
