const express = require("express");
const router = express.Router();
const HiringPost = require("../models/hiring/hiringPost");

const hiringPostService = require("../services/hiringPostService");
const userService = require("../services/userService");


// Create a new hiring post

router.post("/create", async(req, res, next)=>{
    try{
        const post= await hiringPostService.createHiringPost(req.body);
        res.status(200).json({success: true, message: "Hiring post created successfully"});
    }catch(err){
        next(err);
    }
});

router.get("/", async(req, res)=>{
    try{
    const posts= await HiringPost.find({status:"OPEN"});
    res.status(200).json({success: true, data: posts});
    }catch(err){
        res.status(500).json({success: false, message: "Server Error"});
    }
});

router.get("/:id", async(req, res)=>{
  try{
     const post= await HiringPost.findById(req.params.id);
     if(!post){
        return res.status(404).json({success: false, message: "Hiring post not found"});
     }
        res.status(200).json({success: true, data: post});
  }catch(err){
      res.status(500).json({success: false, message: "Server Error"});
  }
});

router.delete("/:id", async(req, res)=>{
  try{
      await HiringPost.findByIdAndDelete(req.params.id);
      res.status(200).json({success: true, message: "Hiring post deleted successfully"});
  }catch(err){
      res.status(500).json({success: false, message: "Server Error"});
  }
});
