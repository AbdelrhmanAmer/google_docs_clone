const express = require("express");
const auth = require("../middleware/auth");
const Document = require("../models/document");
const docRouter = express.Router();

docRouter.post("/doc/create", auth, async (req, res) => {
  try {
    const { createdAt } = req.body;
    let document = Document({
      uid: req.user,
      title: "Untitled document",
      createdAt,
    });
    document = await document.save();
    res.json(document);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

docRouter.delete("/doc/:id", auth, async (req, res) => {
  try {
    const document = await Document.findByIdAndDelete(req.params.id);
    if (!document) {
      res.status(404).json({ error: "Document not found" });
    }
    res.json({ message: "Document deleted successfully", document});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
docRouter.post("/doc/title", auth, async (req, res) => {
  try {
    const { id, title } = req.body;
    const document = await Document.findByIdAndUpdate(id, { title });
    res.json(document);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

docRouter.get("/doc/:id", auth, async (req, res) => {
  try {
    const document = await Document.findById(req.params.id);
    res.json(document);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

docRouter.get("/docs/me", auth, async (req, res) => {
  try {
    let documents = await Document.find({ uid: req.user });
    res.json(documents);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
module.exports = docRouter;
