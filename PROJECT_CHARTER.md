# Project Charter — Developer Portfolio

## Purpose
Build a personal portfolio website for a software developer, treating the whole
process as a hands-on learning experience. We ship the smallest thing that works
end-to-end first (a "Coming Soon" page with a real deploy pipeline), then grow it
into a full portfolio on top of that working foundation.

## Owner
Zac (zacban@gmail.com)

## Guiding principles
- **Learn by doing.** Prefer understanding *why* over just making it work. Each
  step should leave you able to explain it.
- **Ship early, ship often.** A live URL from day one beats a perfect site that
  never deploys.
- **Automate the boring parts.** Once the deploy pipeline exists, publishing is
  just `git push`.
- **Work from anywhere.** Because code lives in a Git repo, the project can be
  driven from a laptop or from a phone via Claude Code on the web.

## Infrastructure (already in place)
- **Web host:** Hostinger **VPS** running Docker. The site is a container
  image (`ghcr.io/zacban/portfolio`) behind the VPS's Traefik reverse proxy, deployed by
  GitHub Actions over SSH. (Was simply.com + FTP until the subscription ended
  in Oct 2026.)
- **Domain:** existing (owned by Zac)
- **Version control / remote:** GitHub — user `zacban`

## .NET backend hosting
Zac wants to build a **C# .NET 10** backend over time. It will run as another
container on the same VPS (`api` service in `deploy/docker-compose.yml`), with
Traefik routing `/api` to it. The ASP.NET Core image runs on Linux, so no
Windows/IIS hosting is needed.

Deploy paths:
- **Frontend (static):** Docker image → ghcr.io → VPS.
- **Backend (.NET, later):** same pipeline, a second image.

---

## Phase 1 — "Coming Soon" + Deploy Pipeline  ✅ COMPLETE
**Goal:** A designed "Coming Soon" placeholder page, automatically deployed to
simply.com every time we push to the main branch.

Deliverables:
1. A single, self-contained static page (`index.html`) — clean, responsive,
   with some visual polish. No framework yet.
2. Git repository, pushed to GitHub.
3. CI/CD pipeline (GitHub Actions) that deploys to simply.com on every push to
   `main`, via FTP/SFTP.
4. The live site reachable at the real domain.

Definition of done:
- Pushing a change to `main` results in the updated page appearing on the domain
  within a couple of minutes, with no manual upload step.

Learning outcomes: Git basics, GitHub, GitHub Actions, secrets management,
FTP/SFTP deploys, DNS/hosting basics.

---

## Phase 2 — Portfolio Foundation  ◀ current
**Goal:** Replace "Coming Soon" with a real (still simple) portfolio structure.

Likely scope:
- Home / hero section (who you are, what you do)
- About section
- Projects section (cards linking to work / GitHub)
- Contact / links (GitHub, LinkedIn, email)
- Responsive layout, consistent design system (colors, type, spacing)

Decision to make: stay hand-written HTML/CSS/JS, or adopt a lightweight
framework (e.g. Astro) for structure and reuse. We'll decide when we get here.

---

## Phase 3 — Content & Polish
- Real project write-ups / case studies
- Accessibility pass (keyboard nav, contrast, semantic HTML)
- Performance pass (Lighthouse)
- SEO basics (meta tags, Open Graph, favicon)
- Optional: light/dark theme, small animations

---

## Phase 4 — Nice-to-haves (backlog)
- Blog / writing section
- Contact form (needs a backend or a form service)
- Analytics (privacy-friendly)
- Custom 404 page

---

## Open questions / to confirm
- [x] ~~simply.com deploy method~~ — superseded by Docker on a Hostinger VPS
- [ ] The exact domain name (set as the `SITE_DOMAIN` repo variable)
- [ ] GitHub account username / whether repo should be public or private
- [ ] Design direction for the Coming Soon page (colors, vibe, wording)

## Changelog
- 2026-07-23 — Charter created. Phase 1 defined and started.
- 2026-07-23 — Phase 1 COMPLETE. Coming Soon page live on domain via GitHub
  Actions → FTP → simply.com. Pipeline verified green. Phase 2 begins.
- 2026-10-14 — simply.com subscription ended. Moved hosting to a Hostinger VPS:
  site now ships as a Docker image (nginx) behind Caddy, deployed via
  GitHub Actions → ghcr.io → SSH `docker compose pull/up`.
- 2026-10-18 — Dropped the bundled Caddy: the VPS already runs Hostinger's
  Traefik on 80/443, so the site container joins its `traefik-proxy` network
  and is routed via labels.
