const mongoose = require("mongoose");
const { Schema } = mongoose;

const DirectMessageSchema = new Schema(
  {
    sender: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    receiver: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    content: {
      type: String,
      required: true,
      trim: true
    },

    sentAt: {
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

// Conversation lookup (A ↔ B)
DirectMessageSchema.index(
  { sender: 1, receiver: 1, sentAt: -1 }
);

// Reverse direction (B ↔ A)
DirectMessageSchema.index(
  { receiver: 1, sender: 1, sentAt: -1 }
);

// Inbox view
DirectMessageSchema.index({ receiver: 1, sentAt: -1 });

module.exports = mongoose.model(
  "DirectMessage",
  DirectMessageSchema
);
