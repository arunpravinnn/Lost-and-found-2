import express from "express";
import dotenv from "dotenv";
import { supabase } from "../db/supabaseClient.js";

dotenv.config();
const userRouter = express.Router();

userRouter.get("/get_items", async (req, res) => {
  try {
    const { data, error } = await supabase.from("Lost_items").select("*");

    if (error) {
      return res.status(400).json({ error: error.message });
    }
    res.json(data);
  } catch (err) {
    console.error("Server error:", err.message);
    res.status(500).json({ error: "Internal server error" });
  }
});

export default userRouter;
