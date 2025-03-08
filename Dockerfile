FROM scottyhardy/docker-remote-desktop:latest

# Set the hostname dynamically
ARG HOSTNAME=$(hostname)
ENV HOSTNAME=$HOSTNAME

# Install curl
RUN apt update && apt install -y curl

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Start the tailscaled service
RUN sudo tailscaled &

# Start Tailscale
RUN sudo tailscale up --auth-key=tskey-auth-ktQ7C93B3e11CNTRL-yuRuqK3qf8FM1FP9FTvU8FLmvwFchaGtM

# Install Python
RUN apt update && apt install -y python3

# Expose RDP port
EXPOSE 3389

# Expose HTTP server port
EXPOSE 8000

# Start the remote desktop and Python HTTP server
CMD ["/bin/bash", "-c", "rm -f /var/run/xrdp/xrdp-sesman.pid && xrdp-sesman && xrdp --nodaemon & python3 -m http.server 8000"]
