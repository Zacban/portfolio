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
ports. The VPS's **Traefik** (Hostinger's default reverse proxy, running with
host networking) owns ports 80/443. It reads the labels in the compose file,
routes `SITE_DOMAIN` (and `www.`) to the container, redirects HTTP to HTTPS,
and handles the Let's Encrypt certificates. Later it will also route `/api` to
the .NET API.

## One-time VPS setup
1. **Docker + Traefik:** the VPS needs Docker with the Compose plugin, and
   Hostinger's Traefik project running (Docker Manager → Traefik template).
   The labels use its entrypoint `websecure` and certificate resolver
   `letsencrypt`.
2. **Deploy user and SSH key:** see the next section.
3. **Firewall:** allow ports 22, 80 and 443 (both in `ufw`, if enabled, and in
   the Hostinger panel's VPS firewall).
4. **DNS:** point the domain's `A` record (and `www`, if wanted) at the VPS IP.

## One-time setup: deploy user and SSH key
GitHub Actions logs **into the VPS** over SSH as a non-root `deploy` user. The
key pair is made on your own PC: the **public** key goes on the VPS, and the
**private** key goes into GitHub as a secret. GitHub's own "SSH keys" and
"Deploy keys" pages are for logging into GitHub, which is the opposite
direction, so they're not used here. The same user and key are shared with the
VPS's other stacks (the private `vps` repo).

1. **Create the deploy user** (on the VPS, as root):
   ```bash
   adduser --disabled-password --gecos "" deploy
   usermod -aG docker deploy
   mkdir -p /home/deploy/.ssh
   chown deploy:deploy /home/deploy/.ssh && chmod 700 /home/deploy/.ssh
   ```
2. **Generate the key pair** (PowerShell on your PC). When it asks for a
   passphrase, press Enter twice. The key **must not have a passphrase**,
   because Actions can't type one:
   ```powershell
   ssh-keygen -t ed25519 -f $HOME\.ssh\vps-deploy -C "github-actions deploy"
   ```
3. **Put the public key on the VPS.** Print it with
   `Get-Content $HOME\.ssh\vps-deploy.pub`, then on the VPS as root:
   ```bash
   echo "PASTE-THE-PUBLIC-KEY-LINE-HERE" >> /home/deploy/.ssh/authorized_keys
   chown deploy:deploy /home/deploy/.ssh/authorized_keys && chmod 600 /home/deploy/.ssh/authorized_keys
   ```
4. **Test the login** from your PC. It should list the containers without
   asking for a password:
   ```powershell
   ssh -i $HOME\.ssh\vps-deploy deploy@<vps-ip> "docker ps"
   ```
5. **Store the private key in GitHub** by piping it in:
   ```powershell
   Get-Content -Raw $HOME\.ssh\vps-deploy | gh secret set VPS_SSH_KEY -R Zacban/portfolio
   ```
   Don't use `gh secret set -f`: `-f` reads a file of `NAME=value` lines and
   fails on a key. Never paste the private key into chats, issues or commits.

**Replacing (rotating) the key:** generate a new one (step 2). On the VPS,
remove the old line with
`sed -i '/github-actions deploy/d' /home/deploy/.ssh/authorized_keys`, then
repeat steps 3–5 (and update the secret in the `vps` repo too).

## One-time setup: GitHub secrets and variables
In the GitHub repo, go to **Settings → Secrets and variables → Actions**.

**Secrets** (encrypted):

| Secret name    | What it is                                   |
| -------------- | -------------------------------------------- |
| `VPS_HOST`     | VPS IP address or hostname                   |
| `VPS_USER`     | The deploy user on the VPS (`deploy`)        |
| `VPS_SSH_KEY`  | The *private* deploy key (see step 5 above)  |

**Variables** (plain text, "Variables" tab):

| Variable name  | What it is                                                   |
| -------------- | ------------------------------------------------------------ |
| `SITE_DOMAIN`  | e.g. `zacban.tech` (required: the deploy stops without it)    |

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
