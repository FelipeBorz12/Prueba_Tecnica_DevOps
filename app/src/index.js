const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Configuración de la conexión a PostgreSQL usando variables de entorno
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/payfast_db'
});

// Endpoint de Salud (Liveness/Readiness Probe)
app.get('/health', async (req, res) => {
  try {
    // Probar la conexión a la base de datos
    await pool.query('SELECT 1');
    res.status(200).json({
      status: 'UP',
      database: 'CONNECTED',
      timestamp: new Date()
    });
  } catch (err) {
    res.status(500).json({
      status: 'DOWN',
      database: 'DISCONNECTED',
      error: err.message,
      timestamp: new Date()
    });
  }
});

// Crear la tabla si no existe (inicialización simple para la demo)
const initDb = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id SERIAL PRIMARY KEY,
        amount DECIMAL(10, 2) NOT NULL,
        currency VARCHAR(3) NOT NULL,
        status VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Database initialized successfully.');
  } catch (err) {
    console.error('Error initializing database:', err.message);
  }
};

// Rutas de Transacciones
app.get('/transactions', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM transactions ORDER BY created_at DESC LIMIT 10');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/transactions', async (req, res) => {
  const { amount, currency, status } = req.body;
  if (!amount || !currency || !status) {
    return res.status(400).json({ error: 'Missing required fields: amount, currency, status' });
  }
  try {
    const { rows } = await pool.query(
      'INSERT INTO transactions (amount, currency, status) VALUES ($1, $2, $3) RETURNING *',
      [amount, currency, status]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Inicializar DB e iniciar servidor
initDb().then(() => {
  app.listen(port, () => {
    console.log(`API running on port ${port}`);
  });
});
