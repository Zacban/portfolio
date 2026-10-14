# The website image: a tiny nginx web server with our static files baked in.
# GitHub Actions builds this and pushes it to ghcr.io/zacban/portfolio.
FROM nginx:1.27-alpine

# Copy the site into nginx's default web root.
# As the site grows (css/, js/, images/), add COPY lines here.
COPY index.html /usr/share/nginx/html/
