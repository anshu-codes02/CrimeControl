const mongoose = require("mongoose");

const { Schema } = mongoose;

const HiringRequestSchema = new Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true
    },

    description: {
      type: String,
      trim: true
    },

    status: {
      type: String,
      enum: ["PENDING", "ACCEPTED", "IN_PROGRESS","DECLINED", "COMPLETED", "CANCELLED"],
      default: "PENDING"
    },

    organization: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    investigator: {
      type: Schema.Types.ObjectId,
      ref: "User"
    },

    crimeCase: {
      type: Schema.Types.ObjectId,
      ref: "CrimeCase"
    },

    proposedRate: {
      type: Number,
      min: 0
    },

    proposedDuration: {
      type: String
    },

    requirements: {
      type: String
    },

    contactInfo: {
      type: String
    },

    organizationMessage: {
      type: String,
      trim: true
    },

    investigatorResponse: {
      type: String,
      trim: true
    },

    requestedAt: {
      type: Date,
      default: Date.now
    },

    respondedAt: {
      type: Date
    },

    acceptedAt: {
      type: Date
    },

    completedAt: {
      type: Date
    }
  },
  {
    timestamps: false
  }
);

module.exports = mongoose.model("HiringRequest", HiringRequestSchema);
