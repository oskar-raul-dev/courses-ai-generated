module.exports = {
  presets: [
    '@quasar/babel-preset-app'
  ],
  env: {
    // Jest corre en Node y necesita CommonJS; el preset de Quasar deja los import para webpack
    test: {
      presets: [
        ['@babel/preset-env', { targets: { node: 'current' } }]
      ]
    }
  }
}
