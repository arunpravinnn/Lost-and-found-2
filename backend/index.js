import express, { Router } from "express"
import cors from "cors"
import dotenv from "dotenv"
import userRouter from "./router/user.router.js"
import adminRouter from "./router/admin.router.js"

const app = express();
app.use(cors());
app.use(express.json());

// routing logic
app.use("/api/user",userRouter);
app.use("/api/user",userRouter);
app.use("/api/admin",adminRouter);
app.use("/api/admin",adminRouter);

// server instance
app.listen(process.env.PORT || 3000,() => {
    console.log("Listening on http://localhost:3000")
})