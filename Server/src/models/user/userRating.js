const mongoose =require("mongoose");


const UserRatingSchema = new mongoose.Schema(
  {
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },

    comment: {
      type: String,
      trim: true
    },

    rater: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    ratedUser: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    crimeCase: {
      type: Schema.Types.ObjectId,
      ref: "CrimeCase"
    },

    type: {
      type: String,
      enum: ["CASE_PERFORMANCE", "COMMUNICATION", "PROFESSIONALISM", "EXPERTISE", "RELIABILITY", "OVERALL"],
      default: "CASE_PERFORMANCE"
    },

    ratedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: false
  }
);

module.exports= mongoose.model("UserRating", UserRatingSchema);
