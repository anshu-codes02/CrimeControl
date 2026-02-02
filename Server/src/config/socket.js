const AppError = require("../utils/appError");
const jwt=require("jsonwebtoken");

module.exports=(io)=>{
    io.use((socket, next)=>{
        try{
             const token = socket.handshake.auth?.token;
             if (!token) {
        throw new AppError("Authentication token missing", 401);
      }
             const decoded = jwt.verify(token, process.env.JWT_SECRET);
             socket.request.user = decoded;

          const user=socket.request.user;
          if(!user) throw new AppError("user not found", 400);
          socket.userId=user.id;
          next();
        }catch(err){
            next(err);
        }
    });

    io.on("connection", (socket)=>{
        socket.join(`user:${socket.userId}`);
        require("../sockets/dmSocket")(io, socket);
    })
}