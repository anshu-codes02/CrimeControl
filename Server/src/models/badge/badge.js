const mongoose = require("mongoose");
const { Schema } = mongoose;

const BadgeSchema = new Schema(
  {
    name: {
      type: String,
      required: true,
      unique: true,   // internal key
      trim: true
    },

    displayName: {
      type: String,
      required: true,
      trim: true
    },

    description: {
      type: String
    },

    icon: {
      type: String
    },

    color: {
      type: String
    },

    type: {
      type: String,
      enum: [
        "CASE_SOLVER", "EXPERT", "RATING", "SPECIALIZATION", "MILESTONE", "ACHIEVEMENT",
   "INNOVATION",
   "ACADEMIC",
   "COMMUNITY",
   "EDUCATION"]
    },

    tier: {
      type: String,
      enum: ["BRONZE", "SILVER", "GOLD", "PLATINUM", "DIAMOND"],
      default: "BRONZE"
    },

    requiredCases: {
      type: Number,
      min: 0
    },

    requiredRating: {
      type: Number,
      min: 0
    },

    requiredCaseType: {
      type: String
    },

    requiredSpecialization: {
      type: String
    },

    active: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

/*INDEXES */

// Unique badge identifier
BadgeSchema.index({ name: 1 }, { unique: true });

// Admin / filtering
BadgeSchema.index({ active: 1 });
BadgeSchema.index({ type: 1, tier: 1 });

module.exports = mongoose.model("Badge", BadgeSchema);
