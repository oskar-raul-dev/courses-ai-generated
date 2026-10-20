var __o = {
var MOCK_USER = {
  username: "admin",
  password: "1234",
  name: "Andrés Felipe Ríos"
};

function login(username, password) {
  if (username === MOCK_USER.username && password === MOCK_USER.password) {
    return {
      token: "mock-jwt-token-123",
      user: { username: MOCK_USER.username, name: MOCK_USER.name }
    };
  }
  throw new Error("Credenciales inválidas");
}

function saveSession(session) {
  localStorage.setItem("token", session.token);
  localStorage.setItem("user", JSON.stringify(session.user));
}

function clearSession() {
  localStorage.removeItem("token");
  localStorage.removeItem("user");
}

function getStoredSession() {
  var token = localStorage.getItem("token");
  var user = JSON.parse(localStorage.getItem("user") || "null");
  return { token: token || "", user: user };
}
module.exports = {
  login: login,
  saveSession: saveSession,
  clearSession: clearSession,
  getStoredSession: getStoredSession
};
};