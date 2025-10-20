// Vercel Serverless entrypoint
// This file will be used by Vercel to handle incoming requests.
// It imports the compiled app from the `dist` folder (built by `npm run build`).

const serverless = require('serverless-http');
const path = require('path');

// Require the built app
const app = require(path.join(__dirname, '..', 'dist', 'src', 'app.js')).default;

module.exports = serverless(app);
