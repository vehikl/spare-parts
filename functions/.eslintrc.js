module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:import/typescript',
    'google',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: ['tsconfig.json', 'tsconfig.dev.json'],
    sourceType: 'module',
  },
  ignorePatterns: [
    '/lib/**/*', // Ignore built files.
    'jest.config.js',
  ],
  plugins: [
    '@typescript-eslint',
    'import',
  ],
  rules: {
    'quotes': ['error', 'single'],
    'semi': ['error', 'never'],
    'import/no-unresolved': 0,
    'require-jsdoc': 0,
    'max-len': ['error', {'code': 120}],
  },
}
