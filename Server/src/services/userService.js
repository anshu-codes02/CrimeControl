const bcrypt=require("bcrypt");
const User=require("../models/user/user");
const jwt=require("jsonwebtoken");
const {AppError}=require("../utils/appError");
const user = require("../models/user/user");
require("dotenv").config();

exports.createUser=async(user)=>{

    const existingUser=await User.findOne({email: user.email});
    if(existingUser){
        throw new Error("Email already in use");
    }


    try{
    user.password=await bcrypt.hash(user.password, 10);
    }catch(error){
        throw new Error("Error hashing password");
    }

    user.emailVerified=false;
    user.organizationVerified=user.role=="ORGANIZATION";
    user.createdAt = new Date();
    user.updatedAt = new Date();

    const newUser=await User.create(user);
    await newUser.save();
    return newUser;
}

exports.authenticateUser=async(data)=>{
    const user=await User.findOne({email: data.email});
    if(!user){
        throw new AppError("User not found", 404);
    }

    const isPasswordValid=await bcrypt.compare(data.password, user.password);
    if(!isPasswordValid){
        throw new AppError("Invalid password", 401);
    }

    const token=jwt.sign(
        {id: user._id, email: user.email, role: user.role},
        process.env.JWT_SECRET,
        {expiresIn: "2h"}
    );
         user.password=undefined; // Remove password from returned user object
    return {
        token,
        user
    };
};

exports.findByUsername=async(username)=>{
    return await User.findOne({username});
};

exports.updateUser=async(user)=>{
    user.updatedAt=new Date();
    const updatedUser=await User.findByIdAndUpdate(user._id, user, {new: true});
    return updatedUser;
}

exports.incrementSolvedCases=async(user, count)=>{
    user.activeCasesCount=count;
    user.updatedAt=new Date();
    return await user.save();
}

exports.addBadge=async(user, badge)=>{
    const user=await User.findById(user);
    const set=new Set(user.badges || []);
    set.add(badge);
    user.badges=[...set];
    user.updatedAt=new Date();
    return await user.save();
}

exports.removeBadge=async(user, badge)=>{
    const set=new Set(user.badges || []);
    set.delete(badge);
    user.badges=[...set];
    user.updatedAt=new Date();
    return await user.save();
}

//EXPERTISE & INTEREST
exports.addExpertiseArea=async(user, expertise)=>{
    const set=new Set(user.expertiseAreas || []);
    set.add(expertise);
    user.expertiseAreas=[...set];
    user.updatedAt=new Date();
    return await user.save();
}

exports.addInterest = (user, interest) => {
  const set = new Set(user.interests || []);
  set.add(interest);

  user.interests = [...set];
  user.updatedAt = new Date();

  return user.save();
};










/*
const bcrypt = require("bcrypt");
const User = require("../models/User");

const UserRole = {
  ORGANIZATION: "ORGANIZATION",
  SOLVER: "SOLVER",
  ADMIN: "ADMIN",
};

// ===== CREATE USER =====
exports.createUser = async (user) => {
  user.password = await bcrypt.hash(user.password, 10);

  user.emailVerified = false;
  user.organizationVerified =
    user.role === UserRole.ORGANIZATION;

  user.createdAt = new Date();
  user.updatedAt = new Date();

  return User.create(user);
};

// ===== UPDATE USER =====
exports.updateUser = (user) => {
  user.updatedAt = new Date();
  return User.findByIdAndUpdate(user._id, user, {
    new: true,
  });
};

// ===== BASIC FINDS =====
exports.findById = (id) => User.findById(id);

exports.findByUsername = (username) =>
  User.findOne({ username });

exports.findByEmail = (email) =>
  User.findOne({ email });

exports.findByUsernameOrEmail = (username, email) =>
  User.findOne({
    $or: [{ username }, { email }],
  });

exports.findAll = () => User.find();

exports.deleteUser = (id) =>
  User.findByIdAndDelete(id);

// ===== ROLE BASED =====
exports.findUsersByRole = (role) =>
  User.find({ role });

exports.findOrganizations = () =>
  User.find({ role: UserRole.ORGANIZATION });

exports.findSolvers = () =>
  User.find({ role: UserRole.SOLVER });

exports.findVerifiedOrganizations = () =>
  User.find({
    role: UserRole.ORGANIZATION,
    organizationVerified: true,
  });

exports.findPendingVerificationOrganizations = () =>
  User.find({
    role: UserRole.ORGANIZATION,
    organizationVerified: false,
  });

// ===== VERIFY ORG =====
exports.verifyOrganization = async (id) => {
  const user = await User.findById(id);

  if (
    !user ||
    user.role !== UserRole.ORGANIZATION
  ) {
    throw new Error(
      "User is not an organization or not found"
    );
  }

  user.organizationVerified = true;
  user.updatedAt = new Date();

  return user.save();
};

exports.rejectOrganization = async (id) => {
  const user = await User.findById(id);

  if (
    !user ||
    user.role !== UserRole.ORGANIZATION
  ) {
    throw new Error(
      "User is not an organization or not found"
    );
  }

  user.organizationVerified = false;
  user.updatedAt = new Date();

  return user.save();
};

// ===== HIRING =====
exports.findAvailableForHireSolvers = () =>
  User.find({
    role: UserRole.SOLVER,
    availableForHire: true,
  });

exports.setAvailableForHire = async (
  userId,
  available,
  hourlyRate
) => {
  const user = await User.findById(userId);

  if (!user || user.role !== UserRole.SOLVER)
    throw new Error(
      "User is not a solver or not found"
    );

  user.availableForHire = available;

  if (hourlyRate != null)
    user.hourlyRate = hourlyRate;

  user.updatedAt = new Date();

  return user.save();
};

// ===== STATS =====
exports.updateUserRating = (user) => {
  user.updatedAt = new Date();
  return user.save();
};

exports.incrementSolvedCases = (user) => {
  user.solvedCasesCount =
    (user.solvedCasesCount || 0) + 1;

  user.updatedAt = new Date();

  return user.save();
};

exports.updateActiveCasesCount = (user, count) => {
  user.activeCasesCount = count;
  user.updatedAt = new Date();

  return user.save();
};

// ===== BADGES =====
exports.addBadge = (user, badge) => {
  const set = new Set(user.badges || []);
  set.add(badge);

  user.badges = [...set];
  user.updatedAt = new Date();

  return user.save();
};

exports.removeBadge = (user, badge) => {
  const set = new Set(user.badges || []);
  set.delete(badge);

  user.badges = [...set];
  user.updatedAt = new Date();

  return user.save();
};

// ===== EXPERTISE & INTEREST =====
exports.addExpertiseArea = (user, expertise) => {
  const set = new Set(user.expertiseAreas || []);
  set.add(expertise);

  user.expertiseAreas = [...set];
  user.updatedAt = new Date();

  return user.save();
};

exports.addInterest = (user, interest) => {
  const set = new Set(user.interests || []);
  set.add(interest);

  user.interests = [...set];
  user.updatedAt = new Date();

  return user.save();
};

// ===== SEARCH SOLVERS =====
exports.findSolversByExpertise = (exp) =>
  User.find({
    role: UserRole.SOLVER,
    expertiseAreas: exp,
  });

exports.findSolversByInterest = (interest) =>
  User.find({
    role: UserRole.SOLVER,
    interests: interest,
  });

exports.findSolversByLocation = (location) =>
  User.find({
    location: { $regex: location, $options: "i" },
  });

exports.findTopSolvers = () =>
  User.find({ role: UserRole.SOLVER })
    .sort({ solvedCasesCount: -1 })
    .limit(10);

exports.findSolversByMinRating = (min) =>
  User.find({
    role: UserRole.SOLVER,
    averageRating: { $gte: min },
  });

exports.findSolversByMinCases = (min) =>
  User.find({
    role: UserRole.SOLVER,
    solvedCasesCount: { $gte: min },
  });

// ===== EMAIL VERIFICATION =====
exports.findByEmailVerificationToken = (token) =>
  User.findOne({ emailVerificationToken: token });

exports.verifyEmail = async (token) => {
  const user = await User.findOne({
    emailVerificationToken: token,
  });

  if (!user)
    throw new Error(
      "Invalid email verification token"
    );

  user.emailVerified = true;
  user.emailVerificationToken = null;
  user.emailVerificationExpiry = null;
  user.updatedAt = new Date();

  return user.save();
};

// ===== PASSWORD RESET =====
exports.findByPasswordResetToken = (token) =>
  User.findOne({ passwordResetToken: token });

exports.setPasswordResetToken = (
  user,
  token,
  expiry
) => {
  user.passwordResetToken = token;
  user.passwordResetExpiry = expiry;
  user.updatedAt = new Date();

  return user.save();
};

exports.resetPassword = async (
  token,
  newPassword
) => {
  const user = await User.findOne({
    passwordResetToken: token,
  });

  if (
    !user ||
    !user.passwordResetExpiry ||
    user.passwordResetExpiry < new Date()
  ) {
    throw new Error(
      "Invalid or expired password reset token"
    );
  }

  user.password = await bcrypt.hash(
    newPassword,
    10
  );

  user.passwordResetToken = null;
  user.passwordResetExpiry = null;
  user.updatedAt = new Date();

  return user.save();
};

// ===== EXISTS =====
exports.existsByUsername = (username) =>
  User.exists({ username });

exports.existsByEmail = (email) =>
  User.exists({ email });

// ===== LAST LOGIN =====
exports.updateLastLogin = (user) => {
  user.lastLoginAt = new Date();
  return user.save();
};

*/