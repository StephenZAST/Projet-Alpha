import express, { Request, Response } from 'express';
const app = express();
const port = 3001;

app.get('/', (req: Request, res: Response) => {
  res.send('Hello from the backend!');
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
