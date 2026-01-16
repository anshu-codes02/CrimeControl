const express = require('express');
const router = express.Router();
const crimeCaseService = require('../services/crimeCaseService');

const CrimeCase = require('../models/case/crimeCase');
const caseCategory = require('../models/enums/caseCategory');
const { auth, isOrganization } = require('../middlewares/auth');

//Get all cases
router.get('/', async (req, res) => {
    try {
        const cases = await CrimeCase.find();
        const summaries = cases.map((c) => ({
            id: c._id,
            title: c.title,
            description: c.description,
            status: c.status || null,
            postedAt: c.postedAt || null,
            imageUrl: c.imageUrl,
            mediaUrl: c.mediaUrl,
            tags: c.tags || [],
            caseType: c.caseType || null,
            difficulty: c.difficulty || null,
            imageUrls: c.imageUrls || [],
        }));

        res.status(200).json({ success: true, data: summaries });

    } catch (err) {
        res.status(500).json({ success: false, message: "Failed to fetch cases" });
    }
});

//get case by id
router.get('/:id', async (req, res) => {
    try {
        const crimeCase = await CrimeCase.findById(req.params.id);
        if (!crimeCase) {
            return res.status(404).json({ success: false, message: "Case not found" });
        }
        res.status(200).json({ success: true, data: crimeCase });
    } catch (err) {
        res.status(500).json({ success: false, message: "Failed to fetch case" });
    }
});

//create a Case
router.post('/', auth, isOrganization, async (req, res) => {
    try {
        const createCase = await crimeCaseService.createCase(req.body, req.user.id);
        res.status(201).json({ success: true, data: createCase });
    } catch (err) {
        res.status(500).json({ success: false, message: "Failed to create case" });
    }
});

//Update a case
router.put('/:id', auth, isOrganization, async (req, res) => {
    try {
        const updatedCase = await crimeCaseService.updateCase(req.params.id, req.body);
        res.status(200).json({ success: true, data: updatedCase });
    } catch (err) {
        res.status(500).json({ success: false, message: "Failed to update case" });
    }
});

//get case Categories
router.get('/categories', async (req, res) => {
    try {
        const categories = Object.values(caseCategory.CaseCategory);
        res.status(200).json({ success: true, data: categories });
    } catch (e) {
        res.status(500).json({ success: false, message: "Failed to fetch case categories" });
    }
});

//related to comments

//get all comments for a case
router.get('/:id/comments', async (req, res) => {
    try {
        const crimeCase = await CrimeCase.findById(req.params.id);
        if (!crimeCase) {
            return res.status(404).json({ success: false, message: "Case not found" });
        }
        const comments = crimeCase.comments.map((c) => ({
            id: c._id,
            userId: c.user?._id || null,
            author: c.user?.username || "Unknown",
            content: c.content,
            createdAt: c.createdAt || null,
        }));

        res.status(200).json({ success: true, data: comments });
    } catch (err) {
        res.status(500).json({ success: false, message: "Failed to fetch case comments" });
    }
});

//add a comment to a case
router.post('/:id/comments', auth, async(req, res)=>{
  try{
     const {content}=req.body;

     if(!content.trim())
     {
        return res.status(400).json({ success: false, message: "Comment content cannot be empty" });

     }

        const crimeCase= await CrimeCase.findById(req.params.id);
        if(!crimeCase){
            return res.status(404).json({ success: false, message: "Case not found" });
        }

        await crimeCaseService.addCommentToCase(req.params.id, req.user.id, content);
        return res.status(200).json({ success: true, message: "Comment added successfully" });
  }catch(err){
    res.status(500).json({ success: false, message: "Failed to add comment to case" });
  }
});


//close case
router.put('/:id/close', auth, isOrganization, async(req, res)=>{
  try{
     const closedCase=await crimeCaseService.closeCase(req.params.id, req.user.id);

        res.status(200).json({ success: true, message: "Case closed successfully",
            case: closedCase
         });
  }catch(err)
  {
    res.status(500).json({ success: false, message: "Failed to close case" });
  }   
});

//delete case
router.delete('/:id', auth, isOrganization, async(req, res)=>{
  try{
     await crimeCaseService.deleteCase(req.params.id, req.user.id);

        res.status(200).json({ success: true, message: "Case deleted successfully" });
  }catch(err)
  {
    res.status(500).json({ success: false, message: "Failed to delete case" });
  }
});   

module.exports = router;















/*
const express = require("express");
const router = express.Router();

const crimeCaseService = require("../services/crimeCaseService");
const userService = require("../services/userService");

const { authMiddleware, requireRole } = require("../middleware/auth");

// ===== CREATE CASE =====
router.post(
  "/",
  authMiddleware,
  requireRole(["ORGANIZATION"]),
  async (req, res) => {
    try {
      const currentUser = await userService.findByUsername(req.user.username);

      if (!currentUser) {
        return res.status(404).json({ error: "User not found" });
      }

      const createdCase = await crimeCaseService.createCase(
        req.body,
        currentUser
      );

      res.json(createdCase);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  }
);

// ===== GET CASE BY ID =====
router.get("/:id", async (req, res) => {
  const crimeCase = await crimeCaseService.findById(req.params.id);

  if (!crimeCase) return res.status(404).end();

  res.json(crimeCase);
});

// ===== UPDATE CASE =====
router.put(
  "/:id",
  authMiddleware,
  requireRole(["ORGANIZATION", "ADMIN"]),
  async (req, res) => {
    try {
      const updated = await crimeCaseService.updateCase(
        req.params.id,
        req.body
      );

      res.json(updated);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  }
);

// ===== GET ALL CASES (SUMMARY) =====
router.get("/", async (req, res) => {
  const cases = await crimeCaseService.findAll();

  const summaries = cases.map((c) => ({
    id: c._id,
    title: c.title,
    description: c.description,
    status: c.status || null,
    postedAt: c.postedAt || null,
    imageUrl: c.imageUrl,
    mediaUrl: c.mediaUrl,
    tags: c.tags || [],
    caseType: c.caseType || null,
    difficulty: c.difficulty || null,
    imageUrls: c.imageUrls || [],
  }));

  res.json(summaries);
});

// ===== PUBLIC CASES =====
router.get("/public", async (req, res) => {
  const cases = await crimeCaseService.findAll();
  res.json(cases);
});

// ===== BY ORGANIZATION =====
router.get("/organization/:organizationId", async (req, res) => {
  const org = await userService.findById(req.params.organizationId);

  if (!org) return res.status(404).json({ error: "Organization not found" });

  const cases = await crimeCaseService.findByPostedBy(org);

  res.json(cases);
});

// ===== BY STATUS =====
router.get("/status/:status", async (req, res) => {
  const cases = await crimeCaseService.findByStatus(req.params.status);
  res.json(cases);
});

// ===== BY TYPE =====
router.get("/type/:type", async (req, res) => {
  const cases = await crimeCaseService.findByCaseType(req.params.type);
  res.json(cases);
});

// ===== BY DIFFICULTY =====
router.get("/difficulty/:difficulty", async (req, res) => {
  const cases = await crimeCaseService.findByDifficulty(
    req.params.difficulty
  );
  res.json(cases);
});

// ===== SEARCH =====
router.get("/search", async (req, res) => {
  const cases = await crimeCaseService.searchByTitleOrDescription(
    req.query.searchTerm
  );
  res.json(cases);
});

// ===== BY TAG =====
router.get("/tags/:tag", async (req, res) => {
  const cases = await crimeCaseService.findByTag(req.params.tag);
  res.json(cases);
});

// ===== ALL TAGS =====
router.get("/tags", async (req, res) => {
  const tags = await crimeCaseService.getAllTags();
  res.json(tags);
});

// ===== CATEGORIES ENUM =====
router.get("/categories", async (req, res) => {
  const categories = await crimeCaseService.getAllCategories();
  res.json(categories);
});

// ===== BY EXPERTISE =====
router.get(
  "/by-expertise",
  authMiddleware,
  async (req, res) => {
    const currentUser = await userService.findByUsername(
      req.user.username
    );

    const cases = await crimeCaseService.findByUserExpertise(
      currentUser
    );

    res.json(cases);
  }
);

// ===== ASSIGN SOLVER =====
router.post(
  "/:id/assign/:solverId",
  authMiddleware,
  requireRole(["ORGANIZATION", "ADMIN"]),
  async (req, res) => {
    const solver = await userService.findById(req.params.solverId);

    if (!solver)
      return res.status(404).json({ error: "Solver not found" });

    const result = await crimeCaseService.assignPrimarySolver(
      req.params.id,
      solver
    );

    res.json(result);
  }
);

// ===== UPDATE STATUS =====
router.post(
  "/:id/status",
  authMiddleware,
  requireRole(["ORGANIZATION", "ADMIN"]),
  async (req, res) => {
    const { status } = req.query;

    switch (status) {
      case "OPEN":
        return res.json(
          await crimeCaseService.reopenCase(req.params.id)
        );

      case "CLOSED":
        return res.json(
          await crimeCaseService.closeCase(req.params.id)
        );

      default:
        return res.json({});
    }
  }
);

// ===== GET COMMENTS =====
router.get("/:id/comments", async (req, res) => {
  const crimeCase = await crimeCaseService.findById(req.params.id);

  if (!crimeCase) return res.status(404).end();

  const comments = crimeCase.comments.map((c) => ({
    id: c._id,
    userId: c.user?._id || null,
    author: c.user?.username || "Unknown",
    content: c.content,
    createdAt: c.createdAt || null,
  }));

  res.json(comments);
});

// ===== ADD COMMENT =====
router.post(
  "/:id/comments",
  authMiddleware,
  async (req, res) => {
    const { content } = req.body;

    if (!content?.trim()) {
      return res
        .status(400)
        .json({ error: "Content is required" });
    }

    const crimeCase = await crimeCaseService.findById(
      req.params.id
    );

    if (!crimeCase) return res.status(404).end();

    const user = await userService.findByUsername(
      req.user.username
    );

    await crimeCaseService.addComment(crimeCase, user, content);

    res.json({ success: true });
  }
);

// ===== CLOSE CASE =====
router.put(
  "/:id/close",
  authMiddleware,
  requireRole(["ORGANIZATION", "ADMIN"]),
  async (req, res) => {
    try {
      const user = await userService.findByUsername(
        req.user.username
      );

      const closedCase = await crimeCaseService.closeCase(
        req.params.id,
        user
      );

      res.json({
        success: true,
        message:
          "Case closed successfully. It can be deleted after 24 hours.",
        case: closedCase,
        deletableAt: closedCase.deletableAt,
        hoursUntilDeletable:
          closedCase.hoursUntilDeletable,
      });
    } catch (err) {
      res.status(400).json({
        success: false,
        error: err.message,
      });
    }
  }
);

// ===== DELETE CASE =====
router.delete(
  "/:id",
  authMiddleware,
  requireRole(["ORGANIZATION", "ADMIN"]),
  async (req, res) => {
    try {
      const user = await userService.findByUsername(
        req.user.username
      );

      await crimeCaseService.deleteCase(
        req.params.id,
        user
      );

      res.json({
        success: true,
        message: "Case deleted successfully",
      });
    } catch (err) {
      res.status(400).json({
        success: false,
        error: err.message,
      });
    }
  }
);

// ===== CAN DELETE =====
router.get("/:id/can-delete", async (req, res) => {
  try {
    const canDelete = await crimeCaseService.canDeleteCase(
      req.params.id
    );

    const crimeCase = await crimeCaseService.findById(
      req.params.id
    );

    res.json({
      canDelete,
      isClosed: crimeCase.isClosed,
      closedAt: crimeCase.closedAt,
      deletableAt: crimeCase.deletableAt,
      hoursUntilDeletable:
        crimeCase.hoursUntilDeletable,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ===== GET DELETABLE (ADMIN) =====
router.get(
  "/deletable",
  authMiddleware,
  requireRole(["ADMIN"]),
  async (req, res) => {
    const cases = await crimeCaseService.getDeletableCases();
    res.json(cases);
  }
);

module.exports = router;

*/