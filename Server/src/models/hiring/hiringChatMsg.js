const mongoose = require("mongoose");

const { Schema } = mongoose;

const HiringChatMessageSchema = new Schema(
  {
    application: {
      type: Schema.Types.ObjectId,
      ref: "HiringApplication",
      required: true
    },

    sender: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    message: {
      type: String,
      required: true,
      trim: true
    },

    timestamp: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: false
  }
);

module.exports = mongoose.model(
  "HiringChatMessage",
  HiringChatMessageSchema
);
