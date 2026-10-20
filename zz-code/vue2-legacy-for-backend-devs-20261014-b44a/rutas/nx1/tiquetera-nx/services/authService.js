var MOCK_USER = { username: "admin", password: "1234", name: "Andrés Felipe Ríos" };

function login(username, password) {
  if (username === MOCK_USER.username && password === MOCK_USER.password) {
    return {
      token: "mock-jwt-token-123",
      user: { username: MOCK_USER.username, name: MOCK_USER.name }
    };
  }
  throw new Error("Credenciales inválidas");
}

export default { login: login };
