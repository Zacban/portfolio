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
- **Web host:** simply.com (existing account) — deploy via **FTP**
- **Domain:** existing (owned by Zac)
- **Version control / remote:** GitHub — user `zacban` (repo to be created)

## .NET backend hosting
Zac wants to build a **C# .NET 10** backend over time. simply.com **does offer
Windows + .NET 10 hosting**, so the backend can live on the same host as the
frontend — no separate VPS/Azure required. The "web deploy" option in the
simply.com panel is Microsoft Web Deploy (msdeploy), the standard way to publish
.NET apps to Windows/IIS.

Planned deploy paths:
- **Frontend (static):** FTP (already set up in Phase 1).
- **Backend (.NET, later):** Web Deploy to the Windows/.NET host.

To confirm when we get to the backend: which simply.com plan/tier includes the
Windows/.NET server, and its Web Deploy endpoint + credentials.

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
- [ ] simply.com deploy method: FTP or SFTP? (affects the GitHub Action)
- [ ] The exact domain name
- [ ] GitHub account username / whether repo should be public or private
- [ ] Design direction for the Coming Soon page (colors, vibe, wording)

## Changelog
- 2026-07-23 — Charter created. Phase 1 defined and started.
- 2026-07-23 — Phase 1 COMPLETE. Coming Soon page live on domain via GitHub
  Actions → FTP → simply.com. Pipeline verified green. Phase 2 begins.
