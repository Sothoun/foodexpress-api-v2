const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Sample in-memory data
const menu = [
  { id: 1, name: 'Margherita Pizza', price: 8.99 },
  { id: 2, name: 'Chicken Burger', price: 6.5 },
  { id: 3, name: 'Veggie Wrap', price: 5.25 }
];

app.get('/', (req, res) => {
  res.json({ message: 'Welcome to FoodExpress API', status: 'running' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.get('/menu', (req, res) => {
  res.json(menu);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`FoodExpress API listening on port ${PORT}`);
});
