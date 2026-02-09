# Ory Kratos on Railway

This repository contains the configuration to deploy [Ory Kratos](https://www.ory.sh/kratos/) on [Railway](https://railway.app/), a modern platform for deploying applications with minimal configuration.

## Overview

Ory Kratos is an open-source identity and user management system that handles user registration, login, account verification, profile management, and more. This setup deploys Kratos v25.4.0 on Railway with PostgreSQL database support.

## Prerequisites

- A [Railway account](https://railway.app/)
- A GitHub account (to connect your repository)
- SMTP credentials for email delivery (e.g., SendGrid, Mailgun, or Gmail)
- A frontend application that integrates with Kratos

## Architecture

This deployment uses a gateway architecture:

- **Gateway (nginx)**: Single public endpoint that routes all traffic
  - `/admin/*` → Kratos Admin API (port 4434) ⚠️ NO AUTH - ADD LATER
  - `/self-service/*`, `/sessions/*`, `/health/*` → Kratos Public API (port 4433)
  - `/relation-tuples` → Keto permissions API
  - `/` → Your UI application
- **Ory Kratos**: Identity server (INTERNAL - not publicly exposed)
  - Public API: port 4433
  - Admin API: port 4434
- **PostgreSQL**: Database for storing identity data (provided by Railway)
- **Email courier**: For sending verification and recovery emails via SMTP

**Railway Configuration:**

- Only the Gateway service needs public exposure
- Kratos, Keto, and UI use Railway's private networking
- Set `KRATOS_INTERNAL` to Kratos service internal URL (e.g., `http://kratos.railway.internal`)

## Quick Deploy to Railway

1. **Fork or push this repository to your GitHub account**

2. **Create a new project on Railway**:
   - Go to [Railway Dashboard](https://railway.app/dashboard)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose this repository

3. **Add PostgreSQL database**:
   - Click "New" → "Database" → "Add PostgreSQL"
   - Railway will automatically create a PostgreSQL database and set the `DATABASE_URL` variable

4. **Configure environment variables** (see section below)

5. **Deploy**: Railway will automatically build and deploy your Kratos instance

## Environment Variables

Configure the following environment variables in your Railway project settings:

### Required Variables

| Variable                      | Description                        | Example                                  |
| ----------------------------- | ---------------------------------- | ---------------------------------------- |
| `DSN`                         | PostgreSQL connection string       | `postgresql://user:pass@host:5432/db`    |
| `KRATOS_PUBLIC_URL`           | Public URL of your Kratos instance | `https://kratos.railway.app`             |
| `KRATOS_UI_URL`               | URL of your frontend UI            | `https://your-app.com`                   |
| `DEFAULT_RETURN_URL`          | Default redirect after auth flows  | `https://your-app.com/dashboard`         |
| `ALLOWED_RETURN_URL`          | Allowed return URL pattern         | `https://your-app.com`                   |
| `CORS_ALLOWED_ORIGIN`         | CORS allowed origin                | `https://your-app.com`                   |
| `SECRETS_DEFAULT`             | Random 32-character secret         | Generate with: `openssl rand -hex 32`    |
| `SECRETS_COOKIE`              | Random 32-character secret         | Generate with: `openssl rand -hex 32`    |
| `COURIER_SMTP_CONNECTION_URI` | SMTP connection string             | `smtp://user:pass@smtp.provider.com:587` |
| `COURIER_SMTP_FROM_ADDRESS`   | Email sender address               | `noreply@yourdomain.com`                 |
| `COURIER_SMTP_FROM_NAME`      | Email sender name                  | `Your App Name`                          |

### Setting up DSN

Railway automatically creates a `DATABASE_URL` variable when you add PostgreSQL. Use this value for `DSN`:

```bash
DSN=${{Postgres.DATABASE_URL}}
```

In Railway, you can reference other service variables using the `${{ServiceName.VARIABLE}}` syntax.

### Generating Secrets

Generate secure random secrets for `SECRETS_DEFAULT` and `SECRETS_COOKIE`:

```bash
openssl rand -hex 32
```

Run this command twice to generate two different secrets.

### SMTP Configuration Examples

#### SendGrid

```
COURIER_SMTP_CONNECTION_URI=smtp://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:587
```

#### Mailgun

```
COURIER_SMTP_CONNECTION_URI=smtp://postmaster@your-domain.com:YOUR_PASSWORD@smtp.mailgun.org:587
```

#### Gmail (with App Password)

```
COURIER_SMTP_CONNECTION_URI=smtp://your-email@gmail.com:YOUR_APP_PASSWORD@smtp.gmail.com:587
```

## Project Structure

```
.
├── Dockerfile              # Docker configuration
├── entrypoint.sh          # Startup script with migrations
├── kratos.yml             # Kratos configuration
├── identity.schema.json   # User identity schema
└── README.md              # This file
```

## Configuration Details

### Kratos Configuration ([kratos.yml](kratos.yml))

The configuration includes:

- **Email-based authentication** with password, TOTP, and recovery codes
- **Session management** with 24-hour lifespan
- **CORS enabled** for frontend integration
- **Self-service flows** for registration, login, settings, recovery, and verification
- **Email courier** for verification and recovery emails

### Identity Schema ([identity.schema.json](identity.schema.json))

The default schema includes:

- Email (required, used for authentication)
- First and last name (optional)
- Email verification and recovery support

You can customize this schema to add additional user traits (e.g., phone number, company name, etc.).

### Dockerfile

Uses the official Ory Kratos image (v25.4.0) with:

- Alpine Linux base
- `envsubst` for environment variable substitution
- Configuration files copied at build time

### Entrypoint Script ([entrypoint.sh](entrypoint.sh))

The entrypoint script:

1. Sets the public port from Railway's `PORT` variable (defaults to 8080)
2. Validates required environment variables
3. Substitutes environment variables in the configuration
4. Runs database migrations automatically
5. Starts Kratos with the courier service

## Accessing Kratos

### Public API

The Public API is exposed on the Railway-provided URL (port 8080):

- Base URL: `https://your-app.railway.app`
- Health: `GET /health/ready`
- Self-service flows: `/self-service/*`
- Sessions: `/sessions/whoami`

### Admin API

The Admin API is only accessible from localhost (127.0.0.1:4434) for security. If you need to access it:

- Use Railway's [private networking](https://docs.railway.app/reference/private-networking)
- Or deploy a separate admin service with SSH access

## Integration with Your Frontend

To integrate Kratos with your frontend application:

1. **Install the Kratos SDK**:

   ```bash
   npm install @ory/client
   ```

2. **Initialize the client**:

   ```javascript
   import { Configuration, FrontendApi } from "@ory/client";

   const kratos = new FrontendApi(
     new Configuration({
       basePath: "https://your-kratos.railway.app",
       baseOptions: {
         withCredentials: true,
       },
     }),
   );
   ```

3. **Implement authentication flows**:
   - Registration: `/self-service/registration/browser`
   - Login: `/self-service/login/browser`
   - Settings: `/self-service/settings/browser`
   - Recovery: `/self-service/recovery/browser`
   - Verification: `/self-service/verification/browser`

4. **Check session**:
   ```javascript
   const session = await kratos.toSession();
   ```

See the [Ory Kratos documentation](https://www.ory.sh/docs/kratos/) for complete integration guides.

## CORS Configuration

Update the CORS configuration in [kratos.yml](kratos.yml) to allow your frontend domain:

```yaml
serve:
  public:
    cors:
      enabled: true
      allowed_origins:
        - https://your-app.com
        - https://www.your-app.com
```

## Database Migrations

Database migrations run automatically on startup via the entrypoint script:

```bash
kratos migrate sql -e --yes
```

This ensures your database schema is always up to date with the Kratos version.

## Monitoring and Logs

View logs in Railway dashboard:

1. Go to your project
2. Select the Kratos service
3. Click on "Deployments" → "View Logs"

Check health endpoint:

```bash
curl https://your-kratos.railway.app/health/ready
```

## Troubleshooting

### Issue: CORS errors in browser

**Solution**: Ensure your frontend domain is listed in `allowed_origins` in [kratos.yml](kratos.yml) and redeploy.

### Issue: Email not sending

**Solution**:

- Verify SMTP credentials are correct
- Check logs for SMTP errors
- Test SMTP connection separately
- Ensure SMTP provider allows the sending domain

### Issue: Database connection failed

**Solution**:

- Verify `DSN` variable is set correctly
- Check PostgreSQL service is running
- Ensure database URL includes correct credentials

### Issue: Environment variables not substituted

**Solution**: The entrypoint script uses `envsubst`. Ensure all referenced variables in `kratos.yml` are set in Railway.

### Issue: Admin API not accessible

**Solution**: The Admin API is intentionally bound to localhost for security. Use Railway's private networking or deploy a separate admin service if needed.

## Security Considerations

1. **Secrets**: Always use cryptographically secure random strings for `SECRETS_DEFAULT` and `SECRETS_COOKIE`
2. **HTTPS**: Railway provides HTTPS by default. Never use HTTP in production
3. **CORS**: Only allow trusted frontend domains in CORS configuration
4. **Admin API**: Keep the Admin API private (localhost only)
5. **Database**: Use Railway's private networking for database connections
6. **Environment Variables**: Never commit secrets to version control

## Updating Kratos

To update to a newer version of Kratos:

1. Update the version in [Dockerfile](Dockerfile):

   ```dockerfile
   FROM oryd/kratos:vX.Y.Z
   ```

2. Review [Kratos changelog](https://github.com/ory/kratos/releases) for breaking changes

3. Update configuration if needed

4. Deploy the changes to Railway

## Resources

- [Ory Kratos Documentation](https://www.ory.sh/docs/kratos/)
- [Railway Documentation](https://docs.railway.app/)
- [Kratos GitHub Repository](https://github.com/ory/kratos)
- [Ory Community Slack](https://slack.ory.sh/)

## Gateway Configuration

All traffic is routed through a separate Gateway service (see `/gateway` folder). The Gateway exposes:

- **Public endpoints**: `/self-service/*`, `/sessions/*`, `/health/*`
- **⚠️ Admin API** (NO AUTH): `/admin/*`

### Security Warning

**The admin API at `/admin/*` is publicly accessible without authentication!**

The admin API has full control over:

- Creating/deleting identities
- Managing sessions
- Full control over your auth system

### TODO: Add Authentication to Admin API

Modify the Gateway's [nginx.conf.template](../gateway/nginx.conf.template) to add authentication:

```nginx
location ^~ /admin/ {
  # Option 1: Basic Auth
  auth_basic "Admin Access";
  auth_basic_user_file /etc/nginx/.htpasswd;

  # Option 2: API Key validation
  if ($http_authorization != "Bearer $ADMIN_API_KEY") {
    return 401 "Unauthorized";
  }

  # Option 3: IP whitelist
  allow 10.0.0.0/8;  # Private network
  deny all;

  proxy_pass ${KRATOS_INTERNAL}:4434/admin/;
  # ... rest of config
}
```

**Recommended solutions:**

- Use OAuth2 Proxy with your identity provider
- Implement API key middleware
- Use Cloudflare Access or similar zero-trust solution
- Keep admin API internal and access via Railway private networking

## License

This configuration is provided as-is for use with Ory Kratos. Ory Kratos is licensed under Apache 2.0.

## Support

For Kratos-specific issues, refer to the [Ory Kratos documentation](https://www.ory.sh/docs/kratos/) or [GitHub issues](https://github.com/ory/kratos/issues).

For Railway-specific issues, check the [Railway documentation](https://docs.railway.app/) or [Discord community](https://discord.gg/railway).
