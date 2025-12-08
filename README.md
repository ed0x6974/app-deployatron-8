# Documentation

This document describes the deployment process for the project


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
   `app_path/front/`
3. Copy backend files to:  
   `app_path/api/`
4. Frontend becomes accessible at:  
   `https://3deploy.shop`
5. Backend becomes accessible at:  
   `https://api.3deploy.shop/`
6. Start the backend using PM2 with `app_path/ecosystem.config.js`

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
   `app_path/staging/feature-b-main/`
2. Generate a dump of the production database.
3. Build the frontend and place built files in:  
   `app_path/staging/feature-b-main/front/`
4. Copy backend files to:  
   `app_path/staging/feature-b-main/api/`
5. Generate a PM2 configuration file:  
   `app_path/staging/feature-b-main/ecosystem.config.js`
6. Create a database user and database, then import the generated dump.
7. Frontend becomes accessible at:  
   `http://feature-b-main.3deploy.shop`
8. Backend becomes accessible at:  
   `http://feature-b-main.3deploy.shop/api`
9. Start the backend using PM2 and `app_path/staging/feature-b-main/ecosystem.config.js`

---

#### After PR close or merge  
Workflow: **[staging-cleanup](./.github/workflows/staging-cleanup.yml)**

1. Kill the PM2 process and remove the directory:  
   `app_path/staging/feature-b-main`
2. Delete all staging files related to the PR environment.
3. Remove the corresponding database user and database.

---
