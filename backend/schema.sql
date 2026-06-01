-- Price Tracker schema for Neon (Postgres)

CREATE TABLE IF NOT EXISTS users (
  uid TEXT PRIMARY KEY,
  name TEXT,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  title TEXT,
  description TEXT,
  url TEXT,
  site TEXT,
  image TEXT
);

CREATE TABLE IF NOT EXISTS price_history (
  id SERIAL PRIMARY KEY,
  product_id TEXT REFERENCES products(id) ON DELETE CASCADE,
  price NUMERIC(12,2) NOT NULL,
  currency TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alerts (
  user_uid TEXT REFERENCES users(uid) ON DELETE CASCADE,
  product_id TEXT REFERENCES products(id) ON DELETE CASCADE,
  target_price NUMERIC(12,2) NOT NULL,
  enabled BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (user_uid, product_id)
);

CREATE TABLE IF NOT EXISTS user_tracked_products (
  user_uid TEXT REFERENCES users(uid) ON DELETE CASCADE,
  product_id TEXT REFERENCES products(id) ON DELETE CASCADE,
  PRIMARY KEY (user_uid, product_id)
);
