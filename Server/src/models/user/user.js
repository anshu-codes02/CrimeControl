const mongoose = require("mongoose");
const { Schema } = mongoose;

const UserSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      index: true
    },

    password: {
      type: String,
      required: true,
      select: false
    },

    firstName: {
      type: String,
      required: true,
      trim: true
    },
    lastName: {
      type: String,
      required: true,
      trim: true
    },
    bio: String,
    expertise: String,
    location: String,
    phoneNumber: String,

    role: {
      type: String,
      enum: ["SOLVER", "RECRUITER", "ADMIN","ORGANIZATION"],
      default: "SOLVER"
    },

    interests: [String],
    expertiseAreas: [String],
    badges: [Number],
    specializationsList: [String],
    
    organizationVerified: {
      type: Boolean,
      default: false
    },
    organizationType: String,
    verificationDocument: String,

    averageRating: {
      type: Number,
      default: 0
    },
    totalRatings: {
      type: Number,
      default: 0
    },

    solvedCasesCount: {
      type: Number,
      default: 0
    },
    activeCasesCount: {
      type: Number,
      default: 0
    },

    availableForHire: {
      type: Boolean,
      default: false
    },
    hourlyRate: Number,

    investigatorBio: String,
    experience: String,
    certifications: String,
    specializations: String,

    emailVerified: {
      type: Boolean,
      default: false
    },
    emailVerificationToken: String,
    emailVerificationExpiry: Date,

    passwordResetToken: String,
    passwordResetExpiry: Date,

    lastLoginAt: Date,

    // 🔗 Relationships
    connections: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],

    // caseParticipations: [
    //   {
    //     type: Schema.Types.ObjectId,
    //     ref: "CaseParticipation"
    //   }
    // ],

    receivedRatings: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "UserRating"
      }
    ],

    givenRatings: [
      {
        type: Schema.Types.ObjectId,
        ref: "UserRating"
      }
    ],

    hiringRequests: [
      {
        type: Schema.Types.ObjectId,
        ref: "HiringRequest"
      }
    ]
  },
  {
    timestamps: true // replaces @PrePersist & @PreUpdate
  }
);

module.exports= mongoose.model("User", UserSchema);
