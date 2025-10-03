const mongoose = require('mongoose');

const documentScheme = mongoose.Schema({
    uid: {
        type: String,
        required: true,
    },
    createdAt: {
        required: true,
        type: String,
    },
    title: {
        required: true,
        type: String,
        trim: true,
    },
    content: {
        type: Array,
        default: [],
    }
})

const Document = mongoose.model('Document', documentScheme);
module.exports = Document;