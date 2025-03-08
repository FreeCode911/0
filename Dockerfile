FROM scottyhardy/docker-remote-desktop:latest

# Set the hostname dynamically
ARG HOSTNAME=$(hostname)
ENV HOSTNAME=$HOSTNAME

# Install ngrok
RUN apt update && apt install -y curl \
    && curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
    | tee /etc/apt/sources.list.d/ngrok.list \
    && apt update && apt install -y ngrok

# Add ngrok authentication token
RUN ngrok config add-authtoken 2u188f0rAEoOF1Km96G6q22KEJ6_6soqrsdpY3ZZGkJek1Bx8

# Install Python
RUN apt update && apt install -y python3

# Expose RDP port
EXPOSE 3389

# Expose HTTP server port
EXPOSE 8000

# Start the remote desktop, ngrok, and Python simple HTTP server, ensuring no stale PID file
CMD ["/bin/bash", "-c", "rm -f /var/run/xrdp/xrdp-sesman.pid && ngrok tcp 3389 & xrdp-sesman && xrdp --nodaemon & python3 -m http.server 8000"]
