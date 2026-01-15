const mongoose = require("mongoose");
const { Schema } = mongoose;

const CaseParticipationSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    crimeCase: {
      type: Schema.Types.ObjectId,
      ref: "CrimeCase",
      required: true
    },

    role: {
      type: String,
      enum: ["PRIMARY_SOLVER", "OWNER",
   "LEADER",
   "SOLVER",
   "FOLLOWER",
   "OBSERVER"],

      default: "FOLLOWER"
    },

    status: {
      type: String,
      enum: [ "ACTIVE",
   "INACTIVE",
   "SUSPENDED",
   "COMPLETED"],
      default: "ACTIVE"
    },

    joinedAt: {
      type: Date,
      default: Date.now
    },

    lastActivityAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: false
  }
);

/* 🔑 INDEXES */

// Prevent duplicate participation (same user, same case)
CaseParticipationSchema.index(
  { user: 1, crimeCase: 1 },
  { unique: true }
);

// Fetch participants of a case
CaseParticipationSchema.index({ crimeCase: 1 });

// Fetch cases a user participates in
CaseParticipationSchema.index({ user: 1 });

// Activity sorting
CaseParticipationSchema.index({ crimeCase: 1, lastActivityAt: -1 });

module.exports = mongoose.model(
  "CaseParticipation",
  CaseParticipationSchema
);
