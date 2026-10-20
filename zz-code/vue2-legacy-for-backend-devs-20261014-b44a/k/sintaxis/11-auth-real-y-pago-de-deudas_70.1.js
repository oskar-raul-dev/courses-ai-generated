function __f(){
// src/models/User.js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  name:     { type: String, required: true },
  role:     { type: String, enum: ["agent", "reporter"], required: true },
  passwordHash: { type: String, required: true }
}, { timestamps: true });   // createdAt/updatedAt automáticos — lo que hiciste a mano en F4

module.exports = mongoose.model("User", userSchema);
}