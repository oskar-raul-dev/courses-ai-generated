var MOCK_USER = {
  username: "admin",
  password: "1234",
  name: "Andrés Felipe Ríos"
};

var FAKE_DELAY = 600; // ms — para que el loading se vea

function login(username, password) {
  return new Promise(function (resolve, reject) {
    setTimeout(function () {
      if (username === MOCK_USER.username && password === MOCK_USER.password) {
        resolve({
          token: "mock-jwt-token-123",
          user: { username: MOCK_USER.username, name: MOCK_USER.name }
        });
      } else {
        reject(new Error("Credenciales inválidas"));
      }
    }, FAKE_DELAY);
  });
}

// saveSession, clearSession y getStoredSession quedan igual que en la Fase 2