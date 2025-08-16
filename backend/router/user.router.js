import express from "express"
import jwt from "jsonwebtoken"
import dotenv from "dotenv"

const userRouter = express.Router()

userRouter.post('/login',(req,res) => {
    // const AccessTocken = jwt.sign(
    //     {"username" : "User"},
    //     process.env.ACCESS_TOKEN_SECRET,
    //     {expiresIn : '600s'}
    // )
    // const RefreshToken = jwt.sign(
    //     {"username" : "User"},
    //     process.env.REFRESH_TOKEN_SECRET,
    //     {expiresIn : '1d'}
    // )
    const { email, password, role } = req.body;
    if (!email || !password || !role) {
        res.status(400).send("Email, password, and role are required");
        return;
    }
    // Example validation (replace with your own logic)
    if (email === "admin@example.com" && password === "adminpass" && role === "admin") {
        // Valid admin
        res.status(200).send("Admin login successful");
    } else if (email === "user@example.com" && password === "userpass" && role === "user") {
        // Valid user
        res.status(200).send("User login successful");
    } else {
        res.status(401).send("Invalid credentials");
    }
})
userRouter.post('/signup',(req,res) => {
    const reponse = req.body;
})

userRouter.get('/me',(req,res) => {
    // get the email and the password from the current user
})

userRouter.get('/items',(req,res) => {
    res.status(200).send({
        // send the array of list items from the database 
    })
})

userRouter.post('/claim',(req,res) =>{
    // get a response code of 200(OK) or 401(unauthorised access)
    const response = req.body;
    res.status(200).send({
        'Access Token' : 123456
    })
})


export default userRouter;

