export default function (context) {
  var $axios = context.$axios;
  var $cookies = context.app.$cookies;
  $axios.onRequest(function (config) {
    var token = $cookies.get("token");
    if (token) {
      config.headers.Authorization = "Bearer " + token;
    }
    return config;
  });
}
