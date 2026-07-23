# Portfolio — zacban

Personal developer portfolio. Built in the open, deployed to simply.com.

See [PROJECT_CHARTER.md](PROJECT_CHARTER.md) for the plan and phases.

## Current status: Phase 1
A designed "Coming Soon" page (`index.html`) with an automated deploy pipeline.

## How deployment works
Every push to the `main` branch triggers a GitHub Actions workflow
([.github/workflows/deploy.yml](.github/workflows/deploy.yml)) that uploads the
site to simply.com over FTP. No manual uploads.

```
edit → git push → GitHub Actions → FTP → simply.com → live site
```

## One-time setup: GitHub secrets
The workflow reads FTP credentials from encrypted repository secrets so they are
never stored in the code. In the GitHub repo, go to:

**Settings → Secrets and variables → Actions → New repository secret**

Create these four secrets (values come from your simply.com control panel):

| Secret name       | What it is                                  |
| ----------------- | ------------------------------------------- |
| `FTP_SERVER`      | FTP host, e.g. `ftp.yourdomain.com`         |
| `FTP_USERNAME`    | FTP username                                |
| `FTP_PASSWORD`    | FTP password                                |
| `FTP_SERVER_DIR`  | Target folder, e.g. `/public_html/` or `/`  |

Once those exist, pushing to `main` deploys automatically.

## Working locally
Just open `index.html` in a browser — it's a self-contained static page,
no build step.
