const mongoose = require("mongoose");
const { Schema } = mongoose;

const CaseFileSchema = new Schema(
  {
    fileName: {
      type: String,
      required: true
    },

    originalFileName: {
      type: String
    },

    fileType: {
      type: String
    },

    filePath: {
      type: String,
      required: true
      // e.g. Firebase Storage URL or S3 URL
    },

    fileSize: {
      type: Number // bytes
    },

    crimeCase: {
      type: Schema.Types.ObjectId,
      ref: "CrimeCase",
      required: true
    },

    uploadedBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    uploadedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: false
  }
);

// Fetch all files of a case (most common query)
CaseFileSchema.index({ crimeCase: 1 });

CaseFileSchema.index({ uploadedBy: 1 });
CaseFileSchema.index({ uploadedAt: -1 });

module.exports = mongoose.model("CaseFile", CaseFileSchema);
