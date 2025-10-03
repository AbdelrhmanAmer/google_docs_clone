const express = require("express");
const auth = require("../middleware/auth");
const Document = require('../models/document');
const docRouter = express.Router();

docRouter.post("/doc/create", auth, async (req, res) => {
  try {
    const { createdAt } = req.body;
    let document = Document({
        uid: req.user,
        title: 'Untitled document',
        createdAt, 
    });
    document = await document.save();
    res.json({document});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = docRouter;