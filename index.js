const AWS = require('aws-sdk');
const uuid = require('uuid').v4;
const fs = require('fs');
const axios = require('axios');

function readFileAsync(file) {
    return new Promise((resolve, reject) => {
        fs.readFile(file, (err, blob) => {
            if (err) return reject(err);
            return resolve(blob);
        })
    });
}

(async () => {
    try {
        const s3 = new AWS.S3();
        const url = await s3.getSignedUrlPromise('putObject', {
            Bucket: 's3-presigned-upload-example',
            Key: `${uuid()}-README.md`,
            Expires: 3000,
            ServerSideEncryption: 'AES256',
            ACL: "private",
            ContentType: "application/octet-stream"
        })

        const requestConfig = {
            method: 'PUT',
            url: url,
            headers: {
                'x-amz-server-side-encryption': 'AES256',
                'x-amz-acl': 'private',
                'Content-Type': 'application/octet-stream'
            },
            data: await readFileAsync('./README.md')
        }

        await axios(requestConfig);
    } catch (error) {
        console.log(error)
    }

})();