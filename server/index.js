const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");

const PORT = process.env.PORT || 3001; // fixed fallback
const app = express();

app.use(cors());
app.use(express.json());
app.use(authRouter);

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

app.listen(PORT, "0.0.0.0", () => {
  console.log(`connected at port ${PORT}`); // fixed template string
});
