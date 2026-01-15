const mongoose = require("mongoose");

const { Schema } = mongoose;

const HiringPostSchema = new Schema(
  {
    recruiter: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    hourlyRate: {
      type: Number, // BigDecimal → Number
      min: 0
    },

    caseType: {
      type: String,
      trim: true
    },

    overview: {
      type: String,
      trim: true
    },

    location: {
      type: String,
      trim: true
    },

    status: {
      type: String,
      enum: ["OPEN", "CLOSED"], // adjust to your HiringPostStatus enum
      default: "OPEN"
    }
  },
  {
    timestamps: { createdAt: true, updatedAt: false }
  }
);

module.exports = mongoose.model("HiringPost", HiringPostSchema);
