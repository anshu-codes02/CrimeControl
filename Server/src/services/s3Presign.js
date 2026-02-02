const {PutObjectCommand, GetObjectCommand}=require("@aws-sdk/client-s3");
const {getSignedUrl}=require("@aws-sdk/s3-request-presigner");
const {s3Client}=require("../config/s3Client");


exports.generateUploadUrl= async ({filename, contentType})=>{
    const key=`case_media/${Date.now()}_${filename}`;

    
    const command=new PutObjectCommand({
        Bucket: process.env.BUCKET_NAME,
        Key: key,
        ContentType: contentType
    });

    const uploadUrl = await getSignedUrl(s3Client, command, {
    expiresIn: 300, // 5 minutes
  });
 console.log(uploadUrl);
 console.log("its working here");
  return {
    uploadUrl,
    fileUrl: `https://${process.env.BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`,
  };

};

exports.generateReadUrl= async(key)=>{

    const command = new GetObjectCommand({
    Bucket: process.env.BUCKET_NAME,
    Key: key,
  });

  return await getSignedUrl(s3Client, command, { expiresIn: 10800 });
}

exports.extractS3Key=(fileUrl)=>{
    const url = new URL(fileUrl);
  return url.pathname.startsWith("/")
    ? url.pathname.substring(1)
    : url.pathname;
}

