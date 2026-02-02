const {S3Client}=require('@aws-sdk/client-s3');


const s3Client= new S3Client({
    region: process.env.AWS_REGION,
    credentials:{
        accessKeyId: process.env.ACCESS_KEYID,
        secretAccessKey: process.env.SECRET_ACCESS_KEY
    }
});


module.exports={s3Client};