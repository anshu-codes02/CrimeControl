const mongoose = require("mongoose");

const { Schema } = mongoose;

const HiringApplicationSchema = new Schema(
  {
    post: {
      type: Schema.Types.ObjectId,
      ref: "HiringPost",
      required: true
    },

    applicant: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    coverLetter: {
      type: String,
      trim: true
    },

    status: {
      type: String,
      enum: ["APPLIED", "SHORTLISTED", "REJECTED", "HIRED"],
      default: "APPLIED"
    }
  },
  {
    timestamps: { createdAt: true, updatedAt: false }
  }
);

module.exports = mongoose.model("HiringApplication", HiringApplicationSchema);
