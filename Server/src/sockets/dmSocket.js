const dmService=require("../services/dmService");


module.exports=(io, socket)=>{
    socket.on("dm:send", async({receiverId, caseId, content})=>{
        
         if (socket.userId.toString() === receiverId.toString()) {
            return;
         }
        const message=await dmService.sendMessage(
            socket.userId,
            receiverId,
            caseId,
            content
        );

        
        io.to(`user:${receiverId}`).emit("dm:new", message);
         io.to(`user:${socket.userId}`).emit("dm:new", message);
    });
};