// [unión de V7: F10 no lo publica]
module.exports = {
  port: Number(process.env.PORT || 3000),
  mongoUri: process.env.MONGO_URL || "mongodb://localhost:27017", // [K6: era MONGO_URI; el curso usa MONGO_URL]
  dbName: process.env.DB_NAME || "tiquetera",
  jwtSecret: process.env.JWT_SECRET || "solo-para-el-curso"
};
