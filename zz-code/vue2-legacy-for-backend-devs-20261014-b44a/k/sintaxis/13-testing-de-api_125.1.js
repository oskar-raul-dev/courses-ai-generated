function __f(){
// jest.config.js
module.exports = {
  testEnvironment: "node",
  // hooks compartidos por suite (custom matchers, beforeEach globales) irían aquí;
  // por ahora vacío — la opción REAL es setupFilesAfterEnv (array), no setupFilesAfterEach
  setupFilesAfterEnv: [],
  globalSetup: "./test/globalSetup.js",
  globalTeardown: "./test/globalTeardown.js"
};
}