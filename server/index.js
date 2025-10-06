const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");
const http = require("http");
const docRouter = require("./routes/document");

const PORT = process.env.PORT || 3001;
const app = express();

const server = http.createServer(app);
const socketIO = require("socket.io");
const Document = require("./models/document");
var io = socketIO(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(docRouter);

const DB =
  "mongodb+srv://12121212aboziad_db_user:SuJzRtVfRwxJNaia@cluster0.jqm7p6f.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connection successful.");
  })
  .catch((err) => {
    console.log(err);
  });

io.on("connection", (socket) => {
  socket.on("join", (documentId) => {
    socket.join(documentId);
    console.log("joined.");
  });

  socket.on("typing", (data) => {
    socket.broadcast.to(data.room).emit("changes", data);
  });
  socket.on("save", (data) => {
    saveData(data);
  });
});

const saveData = async (data) => {
  try {
    const result = await Document.findByIdAndUpdate(
      data.room,
      { content: data.delta },
      { new: true }
    );
    if (!result) console.warn(`Document ${data.room} not found.`);
  } catch (err) {
    console.error(`[SAVE ERROR] Document ${data.room}:`, err.message);
  }
};

server.listen(PORT, "0.0.0.0", () => {
  console.log(`connected at port ${PORT}`);
});
