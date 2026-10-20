import apiClient from "./apiClient";

function getUsers(params) {
  return apiClient.get("/users", { params: params }).then(function (res) {
    return res.data;
  });
}

export default { getUsers: getUsers };
