function __f(){
// vue.config.js
module.exports = {
  // 1) PROXY del dev server — la mejora natural del curso:
  //    el frontend pide a /api (mismo origen: adiós CORS, adiós URL hardcodeada)
  //    y el dev server reenvía a json-server
  devServer: {
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        pathRewrite: { "^/api": "" }
      }
    }
  },
  // 2) publicPath: si la app se sirve bajo una subruta (ej. /tiquetera/)
  publicPath: process.env.NODE_ENV === "production" ? "/tiquetera/" : "/",
  // 3) escotillas a webpack crudo, cuando las perillas no alcanzan:
  configureWebpack: { /* se FUSIONA con la config generada */ }
};
}