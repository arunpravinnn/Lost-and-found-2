import express from "express";
import { createClient } from "@supabase/supabase-js";
import "dotenv/config";
import bcrypt from "bcryptjs";
import multer from "multer";
import { v4 as uuidv4 } from "uuid";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

const storage = multer.memoryStorage();
const upload = multer({ storage });

const adminRouter = express.Router();

/**
 * Admin Login
 */
adminRouter.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const { data, error } = await supabase
      .from("Admin")
      .select("*")
      .eq("email", email)
      .single();

    if (error || !data) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, data.password);

    if (!isMatch) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    res.json({
      message: "Admin Login Successful",
      admin: { email: data.email },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * Admin Signup
 */
adminRouter.post("/signup", async (req, res) => {
  const { email, password } = req.body;

  try {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const { data, error } = await supabase
      .from("Admin")
      .insert([{ email, password: hashedPassword }])
      .select();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      message: "Admin Signup Successful",
      admin: { email: data[0].email },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * Add Lost Item
 */
adminRouter.post("/add_items", upload.single("image"), async (req, res) => {
  try {
    const {
      item_id,
      item_name,
      description,
      location_lost,
      date_lost,
      reported_by_name,
      reported_by_roll,
      created_post,
      securityQuestion, // extra field if frontend sends it
      answer,           // extra field if frontend sends it
    } = req.body;
    let image_url = null;

    // ✅ handle image upload if file exists
    if (req.file) {
      const file = req.file;
      const fileExt = file.originalname.split(".").pop();
      const fileName = `${item_id || "item"}_${uuidv4()}.${fileExt}`;

      const { error: uploadError } = await supabase.storage
        .from("lost-images")
        .upload(fileName, file.buffer, { contentType: file.mimetype });

      if (uploadError) {
        return res
          .status(400)
          .json({ error: "Image Upload Failed: " + uploadError.message });
      }

      const { data: publicUrlData } = supabase.storage
        .from("lost-images")
        .getPublicUrl(fileName);

      image_url = publicUrlData.publicUrl;
    }

    // ✅ insert into Supabase DB
    const { data, error } = await supabase
      .from("Lost_items")
      .insert([
        {
          item_id,
          item_name,
          description,
          location_lost,
          date_lost,
          reported_by_name,
          reported_by_roll,
          created_post,
          image_url,
          security_question: securityQuestion || null,
          answer: answer || null,
        },
      ])
      .select();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.json({
      message: "Item added successfully",
      item: data[0],
    });
  } catch (err) {
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

export default adminRouter;
