const express=require("express");
const router=express.Router();
const userService=require("../services/userService");
const {auth}=require("../middlewares/auth");


// User Registration
router.post("/register", async(req, res) => {
   try{
        const user=await userService.createUser(req.body);

        res.status(200).json({success: true, message: "User registered successfully"});
   }catch(error){
     res.status(500).json({success: false, message: error.message});
   } 
});

//user login

router.post("/login", async(req, res, next)=>{
    try{
        const userData= await userService.authenticateUser(req.body);
        res.status(200).json({success: true, message: "User logged in successfully", token: userData.token, id: userData.user._id,
            role: userData.user.role,
            username: userData.user.username,
            email: userData.user.email
        });

    }catch(err){
        next(err);
    }
});


router.get("/me", auth, async (req, res, next) => {
    try{
  const user = await userService.findByUsername(
    req.user.username
  );

  if (!user) return res.status(404).end();

  res.json(user);
}catch(err){
  next(err);
} 
});


module.exports=router;
