const mongoose = require("mongoose");
const { Schema } = mongoose;

const BadgeAwardSchema = new Schema(
  {
    badge: {
      type: Schema.Types.ObjectId,
      ref: "Badge",
      required: true
    },

    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    awardedBy: {
      type: Schema.Types.ObjectId,
      ref: "User"
    },

    crimeCase: {
      type: Schema.Types.ObjectId,
      ref: "CrimeCase"
    },

    reason: {
      type: String,
      trim: true
    },

    awardedAt: {
      type: Date,
      default: Date.now,
      immutable: true
    }
  },
  {
    timestamps: false
  }
);

/* INDEXES */

// Prevent awarding same badge twice to same user (idempotency)
BadgeAwardSchema.index(
  { badge: 1, user: 1 },
  { unique: true }
);

// Fetch all badges for a user
BadgeAwardSchema.index({ user: 1, awardedAt: -1 });

// Analytics / admin views
BadgeAwardSchema.index({ badge: 1 });
BadgeAwardSchema.index({ crimeCase: 1 });

module.exports = mongoose.model("BadgeAward", BadgeAwardSchema);
