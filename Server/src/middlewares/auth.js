const jwt=require('jsonwebtoken');
require('dotenv').config();

exports.auth=(req,res,next)=>{
    try{
    const token=req.header.authorization.split( " ")[1];

    //check for token
    if(!token)
    {
        return res.status(401).json({success: false, message: "No token, authorization denied"});
    }

    //verify token
    try{
        const decode=jwt.verify(token, process.env.JWT_SECRET);
        req.user=decode;
    }catch(err)
    {
        res.status(401).json({success: false, message: "Token is not valid"});
    }
    next();
}catch(err){
    console.error(err.message);
    res.status(500).json({success: false, message: "authentication failed"});
}
}


exports.isOrganization=(req, res, next)=>{
    try{
    const user=req.user;
    if(user.role !== 'ORGANIZATION'){
        return res.status(401).json({success: false, message: "Access denied, not an organization"});
    }
    next();
    }catch(err){
        console.error(err.message);
        res.status(500).json({success: false, message: "authorization failed"});
    }
}

exports.isSolver=(req, res, next)=>{
    try{
    const user=req.user;
    if(user.role !== 'SOLVER'){
        return res.status(401).json({success: false, message: "Access denied, not a solver"});
    }
    next();
    }catch(err){
        console.error(err.message);
        res.status(500).json({success: false, message: "authorization failed"});
    }
}

exports.isRecruiter=(req, res, next)=>{
    try{
    const user=req.user;
    if(user.role !== 'RECRUITER'){
        return res.status(401).json({success: false, message: "Access denied, not a recruiter"});
    }
    next();
    }catch(err){
        console.error(err.message);
        res.status(500).json({success: false, message: "authorization failed"});
    }
}