var __o = {


function getUsers(params) {
  return apiClient.get("/users", { params: params }).then(function (res) {
    return res.data;
  });
}
module.exports = { getUsers: getUsers };
};