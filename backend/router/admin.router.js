import express from "express";
import { createClient } from "@supabase/supabase-js";
import "dotenv/config";
import bcrypt from "bcryptjs";
import multer from "multer";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

const storage = multer.memoryStorage();
const upload = multer({ storage });

const adminRouter = express.Router();


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

adminRouter.post("/add_items", upload.single("image"), async (req, res) => {
  try {
    const {
      item_name,
      description,
      location_lost,
      date_lost,
      reported_by_name,
      reported_by_roll,
      created_post,
      securityQuestion,
      answer,
    } = req.body;

    function generatePrefix(location) {
      if (!location) return "XX";

      const words = location.trim().split(/\s+/);
      let prefix = "";

      for (let i = 0; i < Math.min(2, words.length); i++) {
        prefix += words[i][0].toUpperCase();
      }

      const lastWord = words[words.length - 1];
      if (!isNaN(lastWord)) {
        prefix += lastWord;
      }

      return prefix;
    }

    const prefix = generatePrefix(location_lost);

    const { data: lastItem, error: fetchError } = await supabase
      .from("Lost_items")
      .select("item_id")
      .ilike("item_id", `${prefix}%`)
      .order("item_id", { ascending: false })
      .limit(1);

    if (fetchError) {
      return res.status(400).json({ error: fetchError.message });
    }

    let newNumber = 1;
    if (lastItem && lastItem.length > 0) {
      const lastId = lastItem[0].item_id;
      const lastNum = parseInt(lastId.slice(prefix.length));
      newNumber = lastNum + 1;
    }

    const item_id = `${prefix}${String(newNumber).padStart(3, "0")}`;

    let image_url = null;

    if (req.file) {
      const file = req.file;
      const fileExt = file.originalname.split(".").pop();
      const fileName = `${item_id}.${fileExt}`;

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
