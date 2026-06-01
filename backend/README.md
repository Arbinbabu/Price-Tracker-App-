Price Tracker Backend (Neon Postgres)

This is a minimal Node/Express backend that connects to a Neon (Postgres) database and exposes simple REST endpoints used by the Flutter app.

Setup

1. Create a Neon project and database. Copy the provided `backend/schema.sql` and run it against your Neon database to create tables.

2. Create a `.env` file in `backend/` using `.env.example` and set `NEON_CONNECTION_STRING`.

3. Install dependencies and run:

```bash
cd backend
npm install
npm run dev
```

Auth (optional)

To enable Firebase ID token verification for secure API calls, set the environment variable `FIREBASE_SERVICE_ACCOUNT_JSON` to the JSON contents of a Firebase service account key (copy the JSON into the env value). The server will initialize Firebase Admin and verify incoming `Authorization: Bearer <idToken>` headers.

Google OAuth (alternate)

If you prefer to use Google OAuth ID tokens issued by Google Sign-In instead of Firebase ID tokens, set `GOOGLE_CLIENT_ID` in the environment (and optionally `USE_OAUTH=true`). The server will verify Google ID tokens sent in `Authorization: Bearer <idToken>` and will upsert the user into the `users` table using the Google `sub` as UID.

The server attempts verification in this order when an Authorization header is present:
1. Firebase Admin (if `FIREBASE_SERVICE_ACCOUNT_JSON` provided)
2. Google OAuth (if `GOOGLE_CLIENT_ID` provided)

If neither is configured, auth verification is skipped (not secure).

Database migration

Run the SQL in `schema.sql` against your Neon database (psql or the Neon UI). Example using `psql`:

```bash
psql "$NEON_CONNECTION_STRING" -f schema.sql
```

Endpoints

- `GET /users/:uid/products` — list products tracked by user
- `POST /users/:uid/products` — body `{ product_id }` to add
- `DELETE /users/:uid/products/:productId` — remove tracked product
- `GET /products/:productId` — get product data
- `GET /products/:productId/priceHistory?limit=30` — get recent price history
- `POST /alerts` — body `{ user_uid, product_id, target_price, enabled }`
- `GET /alerts/:uid/:productId` — get alert for user+product

Notes

- This scaffold assumes the client will provide a `uid` (for example, Firebase Auth UID) and does not implement authentication.
- For production, secure the API with proper authentication (JWT, Firebase token verification, etc.).
- Consider adding background workers or cron jobs to insert price history and evaluate alerts.

If you want, I can:
- Verify the schema against your Neon instance (you'll need to provide connection string),
- Add JWT/Firebase token verification middleware and helper to map Firebase users to `users` rows,
- Update the Flutter app services to use these REST endpoints.
