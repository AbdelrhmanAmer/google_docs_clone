const express = require("express");
const User = require("../models/user");

const authRouter = express.Router();

authRouter.post("/api/signup", async (req, res) => {
  try {
    const { name, email, profilePic } = req.body;
    console.log(`${req.body}`);
    
    let user = await User.findOne({ email: email });

    if(!user){
      user = new User({
        email,
        name,
        profilePic
      });
      // we save in user again to get id
      user = await user.save();
    }
    res.json({user: user});
  } catch (error) {
    res.status(500).json({error: error.message});
  }
});
module.exports = authRouter;