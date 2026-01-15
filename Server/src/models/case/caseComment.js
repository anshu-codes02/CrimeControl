const mongoose = require("mongoose");
const { Schema } = mongoose;

const CaseCommentSchema = new Schema(
  {
    content: {
      type: String,
      required: true,
      trim: true
    },

    crimeCase: {
      type: Schema.Types.ObjectId,
      ref: "CrimeCase",
      required: true
    },

    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: false
  }
);

/* INDEXES */

// Fetch comments of a case (very common)
CaseCommentSchema.index({ crimeCase: 1 });

// Fetch comments by a user (profile, moderation)
CaseCommentSchema.index({ user: 1 });

// Show latest comments first
CaseCommentSchema.index({ crimeCase: 1, createdAt: -1 });

module.exports = mongoose.model("CaseComment", CaseCommentSchema);
