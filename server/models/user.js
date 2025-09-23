const mongoose = require("mongoose");

const userScheme = mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    profilePic: {
        type: String,
        required: true,
    }
});

const User = mongoose.model('User', userScheme);
module.exports = User;