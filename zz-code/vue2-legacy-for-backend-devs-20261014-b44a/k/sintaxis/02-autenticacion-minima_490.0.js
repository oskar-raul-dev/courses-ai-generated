// 1. Login
var session = authService.login(username, password);
authService.saveSession(session);
store.commit("auth/SET_SESSION", session);
router.push("/");

// 2. Guard
if (requiresAuth && !localStorage.getItem("token")) { next("/login"); return; }

// 3. Interceptor
config.headers.Authorization = "Bearer " + token;

// 4. Logout
authService.clearSession();
store.commit("auth/CLEAR_SESSION");
router.push("/login");