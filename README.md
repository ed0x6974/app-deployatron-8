# Documentation

This document describes the deployment process for the project

## Goals

### 1. Speed up the deployment process to the staging environment
When a pull request is created, the branch is automatically deployed to staging, and a ready-to-use link to the deployed app appears in the comments. During testing, the database can be reset to its initial state with a single click. [DEMO](https://github.com/ed0x6974/app-deployatron-8/pull/17).


### 2. Speed up the deployment process to production
When pushing to the `main` branch, the branch is automatically deployed to production.

### 3. Minimize discrepancies between the staging environment and production
Staging environment uses a copy of the production db, the same environment and build. Deployment is fully automated, eliminating the risk of manual errors. We don't change the code between staging and production, only environment variables are modified.


## Deployment Strategy

### 1. Production Deployment

| Trigger        | Environment | Behavior                           | Optional Flags         |
|----------------|------------|-----------------------------------|-----------------------|
| Merge to `main` | Production | Automatically deploys to production | `SKIP_ESLINT` – skip ESLint (for urgent deploys) |

### Notes


- Add `SKIP_ESLINT` to commit message to skip ESLint.

---

### How it works

#### After push to main 
Workflow: **[prod-deploy](./.github/workflows/prod-deploy.yml)**


1. Stop the backend using pm2
2. Build the frontend and place built files in:  
   `<appPath>/front/`
3. Copy backend files to:  
   `<appPath>/api/`
4. Frontend becomes accessible at:  
   `https://<domain>`
5. Backend becomes accessible at:  
   `https://api.<domain>/`
6. Start the backend using PM2 with `<appPath>/ecosystem.config.js`

---

### 2. Staging Deployment (PR-based)

| Trigger           | Environment | Behavior                                   | Optional Flags                    |
|-------------------|-------------|---------------------------------------------|-----------------------------------|
| Any Pull Request  | Staging     | Deploys the PR to a dedicated staging env   | `SKIP_STAGING` – skip staging deploy |

### Notes

- After a staging deployment, the workflow automatically adds a PR comment with a **link to the deployed frontend**, allowing reviewers and QA to quickly test the preview.
- The staging database can be reset to its initial state (created during the very first staging deployment from the production DB). Use the workflow **[staging-reset-db](./.github/workflows/staging-reset-db.yml)**.
- Add the `SKIP_STAGING` flag to the **PR title** to skip staging deployment.

---

### How it works

Every pull request generates a unique staging environment name based on the PR branch pair:  
`<headRef>-<baseRef>` (e.g. `feature-b-main`).

---

#### After PR creation  
Workflow: **[staging-deploy](./.github/workflows/staging-deploy.yml)**

1. Create a directory:  
   `<appPath>/staging/feature-b-main/`
2. Generate a dump of the production database.
3. Build the frontend and place built files in:  
   `<appPath>/staging/feature-b-main/front/`
4. Copy backend files to:  
   `<appPath>/staging/feature-b-main/api/`
5. Generate a PM2 configuration file:  
   `<appPath>/staging/feature-b-main/ecosystem.config.js`
6. Create a database user and database, then import the generated dump.
7. Frontend becomes accessible at:  
   `http://feature-b-main.<domain>`
8. Backend becomes accessible at:  
   `http://feature-b-main.<domain>/api`
9. Start the backend using PM2 and `<appPath>/staging/feature-b-main/ecosystem.config.js`

---

#### After PR close or merge  
Workflow: **[staging-cleanup](./.github/workflows/staging-cleanup.yml)**

1. Kill the PM2 process and remove the directory:  
   `<appPath>/staging/feature-b-main`
2. Delete all staging files related to the PR environment.
3. Remove the corresponding database user and database.

---

## Server configuration
This section describes the required server-side setup for a successful deployment.

### 1. Nginx configuration
Nginx must be installed and configured to proxy requests to the application. **[Ready-to-use Nginx configuration file](./docs/nginx-configuration)**

### 2. User permissions

The deployment user must have minimal required privileges.
1) Create a dedicated user (e.g. deployatron)
2) Disable SSH root login
3) Grant access only to the application directory (APP_PATH)
4) The user owns the application files
5) No unrestricted sudo access
6) Never run the application as root

### 3. Install Node.js and PM2
The installed Node.js version MUST exactly match the NODE_VERSION environment variable defined in the repository.

### 4. Application binaries
1) `<repository>/bin → <APP_PATH>/bin`
2) Make all files executable
3) Set correct ownership

### 5. Wildcard subdomains
DNS record: `*.example.com → SERVER_IP`

## Repository configuration
To run the CI/CD pipeline correctly, you must configure the following **Environment Variables** in the repository settings. All variables listed below must be added to the **`deploy`** environment.

### Environment variables

| Name          | Example value                           | Environment | Description |
|---------------|---------------------------------|-------------|-------------|
| APP_PATH      | /var/www/html/app-deployatron-8 | deploy      | Path on the server where the application is deployed |
| FRONT_HOST    | 3deploy.shop                    | deploy      | Frontend domain or host |
| NODE_VERSION  | 18.19.1                         | deploy      | Node.js version used in CI/CD |
| PG_HOST       | localhost                       | deploy      | PostgreSQL host |
| PG_PORT       | 5432                            | deploy      | PostgreSQL port |
| SERVER_IP     | 91.98.202.21                    | deploy      | Target server IP address |
| USER_NAME     | deployatron                     | deploy      | Server user used for deployment |

### Notes

- All variables must be configured in the repository **Environment variables** section.
- The environment name must be **`deploy`**.
- Update the values when changing server, domain, or infrastructure.

### Environment secrets

The following **Environment Secrets** must be configured for the CI/CD pipeline.  
All secrets are added to the **`deploy`** environment and **must never be committed to the repository**.


| Name                  | Environment | Description |
|-----------------------|-------------|-------------|
| PG_PROD_DB_NAME       | deploy      | Name of the production PostgreSQL database |
| PG_PROD_USER_NAME     | deploy      | Username for accessing the production database |
| PG_PROD_USER_PASS     | deploy      | Password for the production database user |
| PG_STAGING_USER_PASS  | deploy      | Password for the staging database user |
| PG_SUPER_USER_NAME    | deploy      | PostgreSQL superuser name |
| PG_SUPER_USER_PASS    | deploy      | PostgreSQL superuser password |
| SSH_PRIVATE_KEY       | deploy      | Private SSH key used to connect to the deployment server |

### Notes

- All secrets must be added in the repository **Environment secrets** settings.
- Environment name must be **`deploy`**.
- `SSH_PRIVATE_KEY` must correspond to a public key added to the server’s `authorized_keys`.
