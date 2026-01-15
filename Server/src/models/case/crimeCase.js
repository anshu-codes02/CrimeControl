const mongoose = require("mongoose");
const { Schema } = mongoose;

const CrimeCaseSchema = new Schema(
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

    location: {
      type: String
    },

    caseType: {
      type: String,
      enum: ["THEFT", "CYBER", "OTHER", "MURDER",
   "FRAUD",
   "ROBBERY",
   "MISSING_PERSON",
   "DRUGS",
   "ASSAULT",
   "FORGERY",
   "ARSON",
]
    },

    difficulty: {
      type: String,
      enum: ["EASY", "MEDIUM", "HARD","EXPERT"],
    },

    status: {
      type: String,
      enum: ["OPEN", "IN_PROGRESS", "SOLVED", "CLOSED"],
      default: "OPEN"
    },

    privacy: {
      type: String,
      enum: ["PUBLIC", "PRIVATE", "RESTRICTED"],
      default: "PUBLIC"
    },

    postedBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    primarySolver: {
      type: Schema.Types.ObjectId,
      ref: "User"
    },

    assignedSolvers: [
      {
        type: Schema.Types.ObjectId,
        ref: "User"
      }
    ],

    solvedBy: {
      type: Schema.Types.ObjectId,
      ref: "User"
    },

    solution: String,
    solutionNotes: String,

    incidentDate: Date,

    solvedAt: Date,
    closedAt: Date,
    deletableAt: Date,

    badgeAwarded: {
      type: Boolean,
      default: false
    },

    awardedBadge: String,
    badgeAwardedAt: Date,

    imageUrl: String,
    mediaUrl: String,

    imageUrls: [String],

    // References
    files: [{ type: Schema.Types.ObjectId, ref: "CaseFile" }],
    comments: [{ type: Schema.Types.ObjectId, ref: "CaseComment" }],
    participations: [{ type: Schema.Types.ObjectId, ref: "CaseParticipation" }],
    evidences: [{ type: Schema.Types.ObjectId, ref: "Evidence" }],
    suspects: [{ type: Schema.Types.ObjectId, ref: "Suspect" }],
    leads: [{ type: Schema.Types.ObjectId, ref: "Lead" }],
    ratings: [{ type: Schema.Types.ObjectId, ref: "UserRating" }],

    tags: [String]
  },
  {
    timestamps: { createdAt: "postedAt", updatedAt: "updatedAt" }
  }
);

module.exports = mongoose.model("CrimeCase", CrimeCaseSchema);
