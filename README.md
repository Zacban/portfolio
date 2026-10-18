# Portfolio — zacban

Personal developer portfolio. Built in the open, deployed as a Docker container
to a Hostinger VPS.

See [PROJECT_CHARTER.md](PROJECT_CHARTER.md) for the plan and phases.

## Current status: Phase 2
A designed "Coming Soon" page (`index.html`) with an automated deploy pipeline.

## How deployment works
Every push to the `main` branch triggers a GitHub Actions workflow
([.github/workflows/deploy.yml](.github/workflows/deploy.yml)) that:

1. Builds the site into a Docker image ([Dockerfile](Dockerfile) — nginx with
   the site files baked in) and pushes it to `ghcr.io/zacban/portfolio`, tagged
   with `latest` and the commit SHA.
2. SSHes into the VPS, copies over [deploy/docker-compose.yml](deploy/docker-compose.yml),
   then pulls the new image and restarts the container.

```
edit → git push → GitHub Actions → build image → ghcr.io → VPS pulls → live site
```

On the VPS, the **web** container (nginx) serves the site. It publishes no
ports. The VPS's **Traefik** (Hostinger's default reverse proxy) owns ports
80/443. It reads the labels in the compose file, routes `SITE_DOMAIN` (and
`www.`) to the container over the shared `traefik-proxy` network, and handles
the Let's Encrypt certificates. Later it will also route `/api` to the .NET API.

## One-time VPS setup
1. **Docker + Traefik:** the VPS needs Docker with the Compose plugin, and
   Hostinger's Traefik project running (Docker Manager → Traefik template).
   Check that `docker network ls` lists `traefik-proxy`. If the name differs,
   update it in [deploy/docker-compose.yml](deploy/docker-compose.yml), along
   with the `websecure` entrypoint and `letsencrypt` resolver names if those
   differ too.
2. **Deploy user:** use a non-root user in the `docker` group
   (`sudo usermod -aG docker <user>`, then log out and back in).
3. **SSH key for GitHub Actions:** on your own machine, create a key just for
   deploys:
   ```bash
   ssh-keygen -t ed25519 -f portfolio-deploy -C "github-actions deploy" -N ""
   ```
   Add the contents of `portfolio-deploy.pub` to `~/.ssh/authorized_keys` for
   the deploy user on the VPS. The private key (`portfolio-deploy`) goes into
   the `VPS_SSH_KEY` secret below.
4. **Firewall:** allow ports 22, 80 and 443 (both in `ufw`, if enabled, and in
   the Hostinger panel's VPS firewall).
5. **DNS:** point the domain's `A` record (and `www`, if wanted) at the VPS IP.

## One-time setup: GitHub secrets and variables
In the GitHub repo, go to **Settings → Secrets and variables → Actions**.

**Secrets** (encrypted):

| Secret name    | What it is                                   |
| -------------- | -------------------------------------------- |
| `VPS_HOST`     | VPS IP address or hostname                   |
| `VPS_USER`     | The deploy user on the VPS                   |
| `VPS_SSH_KEY`  | The *private* deploy key (whole file)        |

**Variables** (plain text, "Variables" tab):

| Variable name  | What it is                                                   |
| -------------- | ------------------------------------------------------------ |
| `SITE_DOMAIN`  | e.g. `zacban.dk` (required: the deploy stops without it)    |

Traefik can only get an HTTPS certificate once DNS for `SITE_DOMAIN` (and
`www.`) points at the VPS.

The old `FTP_*` secrets from the simply.com setup can be deleted.

## Rolling back
Every deploy is tagged with its commit SHA. To go back on the VPS:
```bash
cd ~/portfolio
sed -i 's/^IMAGE_TAG=.*/IMAGE_TAG=<older-commit-sha>/' .env
docker compose up -d
```
(If the image isn't on the VPS anymore and the ghcr.io package is private, run
`docker login ghcr.io` first with a GitHub token that has `read:packages`.)

## Working locally
Just open `index.html` in a browser — it's a self-contained static page,
no build step. To run the real container:
```bash
docker build -t portfolio . && docker run --rm -p 8080:80 portfolio
```
then open <http://localhost:8080>.
