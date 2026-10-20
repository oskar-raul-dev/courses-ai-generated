function __f(){
// src/services/attachments.service.js (extracto)
const { GridFSBucket, ObjectId } = require("mongodb");
const { getDb } = require("../db");

function bucket() { return new GridFSBucket(getDb(), { bucketName: "attachments" }); }

function upload(file, ticketId, username) {
  return new Promise(function (resolve, reject) {
    const stream = bucket().openUploadStream(file.originalname, {
      contentType: file.mimetype,
      metadata: { ticketId: new ObjectId(ticketId), uploadedBy: username,
                  uploadedAt: new Date() }
    });
    stream.on("error", reject);
    stream.on("finish", function () {
      resolve({ id: stream.id.toHexString(), filename: file.originalname,
                contentType: file.mimetype, size: file.size });
    });
    stream.end(file.buffer);
  });
}

async function download(id, res) {
  const files = await getDb().collection("attachments.files")
    .find({ _id: new ObjectId(id) }).toArray();
  if (!files.length) return false;                  // el controller da el 404
  const f = files[0];
  res.set("Content-Type", f.contentType || "application/octet-stream");
  res.set("Content-Disposition", 'attachment; filename="' + f.filename + '"');
  bucket().openDownloadStream(f._id).pipe(res);     // stream, no buffer: 200 MB no matan tu RAM
  return true;
}
}