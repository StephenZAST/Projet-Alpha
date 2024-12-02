import express, { Request, Response } from 'express';
import { config } from './src/config'; // Import the config object

const app = express();
const port = config.port; // Use the port from the config object

app.get('/', (req: Request, res: Response) => {
  res.send('Hello from the backend!');
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
