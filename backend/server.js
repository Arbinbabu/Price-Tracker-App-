require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const admin = require('firebase-admin');
const { OAuth2Client } = require('google-auth-library');

const app = express();
app.use(cors());
app.use(express.json());

const connectionString = process.env.NEON_CONNECTION_STRING;
if (!connectionString) {
  console.error('NEON_CONNECTION_STRING is not set in environment');
  process.exit(1);
}

const pool = new Pool({
  connectionString,
  ssl: { rejectUnauthorized: false },
});

// Initialize Firebase Admin if service account provided
if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
  try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    console.log('Firebase admin initialized');
  } catch (e) {
    console.error('Failed to initialize Firebase admin:', e.message);
  }
} else {
  console.log('No FIREBASE_SERVICE_ACCOUNT_JSON provided; auth middleware will be disabled');
}

// Initialize Google OAuth client if configured
let googleClient = null;
if (process.env.GOOGLE_CLIENT_ID) {
  googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
  console.log('Google OAuth client configured');
} else {
  console.log('No GOOGLE_CLIENT_ID provided; Google OAuth verification disabled');
}

app.get('/', (req, res) => res.send('Price Tracker backend (Neon)'));

// Get tracked products for a user
app.get('/users/:uid/products', authenticateOptional, async (req, res) => {
  const uid = req.params.uid;
  try {
    const result = await pool.query(
      `SELECT p.* FROM products p
       JOIN user_tracked_products utp ON utp.product_id = p.id
       WHERE utp.user_uid = $1`,
      [uid]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

// Add product to user's tracked list
app.post('/users/:uid/products', async (req, res) => {
  const uid = req.params.uid;
  const { product_id } = req.body;
  if (!product_id) return res.status(400).json({ error: 'missing_product_id' });
  try {
    await pool.query(
      `INSERT INTO user_tracked_products (user_uid, product_id)
       VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [uid, product_id]
    );
    res.status(204).end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

// Remove product from user's tracked list
app.delete('/users/:uid/products/:productId', async (req, res) => {
  const uid = req.params.uid;
  const productId = req.params.productId;
  try {
    await pool.query(
      `DELETE FROM user_tracked_products WHERE user_uid = $1 AND product_id = $2`,
      [uid, productId]
    );
    res.status(204).end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

// Get product
app.get('/products/:productId', async (req, res) => {
  const productId = req.params.productId;
  try {
    const result = await pool.query(`SELECT * FROM products WHERE id = $1`, [productId]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'not_found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

// Get price history
app.get('/products/:productId/priceHistory', async (req, res) => {
  const productId = req.params.productId;
  const limit = parseInt(req.query.limit || '30', 10);
  try {
    const result = await pool.query(
      `SELECT * FROM price_history WHERE product_id = $1 ORDER BY timestamp DESC LIMIT $2`,
      [productId, limit]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

// Set alert
app.post('/alerts', async (req, res) => {
  const { user_uid, product_id, target_price, enabled } = req.body;
  if (!user_uid || !product_id || target_price == null) return res.status(400).json({ error: 'invalid_payload' });
  try {
    await pool.query(
      `INSERT INTO alerts (user_uid, product_id, target_price, enabled)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_uid, product_id) DO UPDATE SET target_price = EXCLUDED.target_price, enabled = EXCLUDED.enabled`,
      [user_uid, product_id, target_price, enabled ?? true]
    );
    res.status(204).end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

// Get user alert for a product
app.get('/alerts/:uid/:productId', async (req, res) => {
  const uid = req.params.uid;
  const productId = req.params.productId;
  try {
    const result = await pool.query(`SELECT * FROM alerts WHERE user_uid = $1 AND product_id = $2`, [uid, productId]);
    if (result.rows.length === 0) return res.json(null);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`Server running on port ${port}`));

// --- Auth middleware helpers ---
async function ensureUserExists(uid, displayName = null, email = null) {
  try {
    await pool.query(
      `INSERT INTO users (uid, name, email)
       VALUES ($1, $2, $3)
       ON CONFLICT (uid) DO UPDATE SET name = COALESCE(EXCLUDED.name, users.name), email = COALESCE(EXCLUDED.email, users.email)`,
      [uid, displayName, email]
    );
  } catch (e) {
    console.error('ensureUserExists error', e);
  }
}

function authenticateOptional(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) return next();
  const idToken = authHeader.split(' ')[1];

  // Prefer Firebase Admin verification if initialized
  if (admin.apps.length) {
    admin
      .auth()
      .verifyIdToken(idToken)
      .then((decoded) => {
        req.user = decoded;
        ensureUserExists(decoded.uid, decoded.name || null, decoded.email || null);
        next();
      })
      .catch((err) => {
        console.error('firebase token verify failed', err.message);
        // fall through to OAuth verification
        tryGoogleVerify(idToken, req, next);
      });
    return;
  }

  // Try Google OAuth verification if enabled
  tryGoogleVerify(idToken, req, next);
}

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) return res.status(401).json({ error: 'missing_auth' });
  const idToken = authHeader.split(' ')[1];

  if (admin.apps.length) {
    admin
      .auth()
      .verifyIdToken(idToken)
      .then((decoded) => {
        req.user = decoded;
        ensureUserExists(decoded.uid, decoded.name || null, decoded.email || null).then(() => next());
      })
      .catch((err) => {
        console.error('firebase token verify failed', err.message);
        // try Google OAuth
        verifyGoogleToken(idToken)
          .then((payload) => {
            if (!payload) return res.status(401).json({ error: 'invalid_token' });
            req.user = { uid: payload.sub, name: payload.name, email: payload.email };
            ensureUserExists(req.user.uid, req.user.name || null, req.user.email || null).then(() => next());
          })
          .catch(() => res.status(401).json({ error: 'invalid_token' }));
      });
    return;
  }

  // No Firebase admin; use Google OAuth if available
  verifyGoogleToken(idToken)
    .then((payload) => {
      if (!payload) return res.status(401).json({ error: 'invalid_token' });
      req.user = { uid: payload.sub, name: payload.name, email: payload.email };
      ensureUserExists(req.user.uid, req.user.name || null, req.user.email || null).then(() => next());
    })
    .catch((err) => {
      console.error('google token verify failed', err && err.message);
      res.status(401).json({ error: 'invalid_token' });
    });
}

async function verifyGoogleToken(idToken) {
  if (!googleClient) return null;
  try {
    const ticket = await googleClient.verifyIdToken({ idToken, audience: process.env.GOOGLE_CLIENT_ID });
    return ticket.getPayload();
  } catch (e) {
    console.error('verifyGoogleToken error', e.message);
    return null;
  }
}

function tryGoogleVerify(idToken, req, next) {
  verifyGoogleToken(idToken)
    .then((payload) => {
      if (!payload) return next();
      req.user = { uid: payload.sub, name: payload.name, email: payload.email };
      ensureUserExists(req.user.uid, req.user.name || null, req.user.email || null).then(() => next());
    })
    .catch(() => next());
}
