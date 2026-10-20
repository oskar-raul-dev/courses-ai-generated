// [unión de V7]
const service = require("../services/attachments.service");
async function upload(req, res, next) {
  try { res.status(201).json(await service.upload(req.file, req.body.ticketId, req.user.sub)); } catch (err) { next(err); }
}
async function download(req, res, next) {
  try { if (!(await service.download(req.params.id, res))) res.status(404).json({}); } catch (err) { next(err); }
}
module.exports = { upload, download };
