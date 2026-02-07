const jwt=require('jsonwebtoken');

exports.auth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: "No token, authorization denied",
      });
    }

    const token = authHeader.split(" ")[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next(); // ✅ only reached if token is valid
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: "Token is not valid",
    });
  }
};



exports.isOrganization=(req, res, next)=>{
    try{
    const user=req.user;
    if(user.role !== 'ORGANIZATION'){
        return res.status(403).json({success: false, message: "Access denied, not an organization"});
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
        return res.status(403).json({success: false, message: "Access denied, not a solver"});
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
        return res.status(403).json({success: false, message: "Access denied, not a recruiter"});
    }
    next();
    }catch(err){
        console.error(err.message);
        res.status(500).json({success: false, message: "authorization failed"});
    }
}

exports.isAdmin=(req, res, next)=>{
    try{
    const user=req.user;
    if(user.role !== 'ADMIN'){
        return res.status(403).json({success: false, message: "Access denied, not an admin"});
    }
    next();
    }catch(err){
        console.error(err.message);
        res.status(500).json({success: false, message: "authorization failed"});
    }
}