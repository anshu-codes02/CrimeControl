const dmService=require("../services/dmService");


module.exports=(io, socket)=>{
    socket.on("dm:send", async({receiverId, content})=>{
        const message=await dmService.sendMessage(
            socket.userId,
            receiverId,
            content
        );

        io.to(`user:${receiverId}`).emit("dm:new", message);
         io.to(`user:${socket.userId}`).emit("dm:new", message);
    });
};