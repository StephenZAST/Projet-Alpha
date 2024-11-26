module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": ["off"],
    "linebreak-style": ["off"],
    "max-len": ["warn", {"code": 120}],
    "arrow-parens": ["off"],
    "object-curly-spacing": ["off"],
    "no-unused-vars": ["warn"],
    "new-cap": ["off"], // Disable the new-cap rule
  },
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: "module",
  },
};
