FROM scottyhardy/docker-remote-desktop:latest

# Set the hostname dynamically
ARG HOSTNAME=$(hostname)
ENV HOSTNAME=$HOSTNAME

# Install curl to fetch the cloudflared package
RUN apt update && apt install -y curl \
    && curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared.deb

# Install Python
RUN apt update && apt install -y python3

# Expose RDP port
EXPOSE 3389

# Expose HTTP server port
EXPOSE 8000

# Define the Cloudflare Tunnel token as an environment variable (avoid hardcoding it)
# Replace the token below with a secure method (e.g., Docker secrets or build args)
ARG CLOUDFLARE_TOKEN
ENV CLOUDFLARE_TOKEN=eyJhIjoiODZiZDAxODBhODRlYThiZDQ5MDIwOWRmODM4MmRmZWMiLCJ0IjoiOGI3MTM2Y2QtMTNjZi00YjVjLWI1MjUtOWY2YmI5ZDkzZDExIiwicyI6Ik56RmlabVJtTlRZdE9USm1PQzAwT0RreUxXSTBaVFl0WkRJM1pqaGtNRE5qTnpSaiJ9

# Run the Cloudflare tunnel, xrdp, and Python HTTP server
CMD ["/bin/bash", "-c", "rm -f /var/run/xrdp/xrdp-sesman.pid && cloudflared tunnel --no-autoupdate run --token eyJhIjoiODZiZDAxODBhODRlYThiZDQ5MDIwOWRmODM4MmRmZWMiLCJ0IjoiOGI3MTM2Y2QtMTNjZi00YjVjLWI1MjUtOWY2YmI5ZDkzZDExIiwicyI6Ik56RmlabVJtTlRZdE9USm1PQzAwT0RreUxXSTBaVFl0WkRJM1pqaGtNRE5qTnpSaiJ9 & xrdp-sesman && xrdp --nodaemon & python3 -m http.server 8000"]
