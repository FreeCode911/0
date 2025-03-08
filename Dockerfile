FROM scottyhardy/docker-remote-desktop:latest

# Set the hostname dynamically
ARG HOSTNAME=$(hostname)
ENV HOSTNAME=$HOSTNAME

# Install LocalXpose
RUN apt update && apt install -y curl \
    && curl -sSL https://loclx-client.s3.amazonaws.com/loclx-linux-arm64.deb -o /tmp/loclx.deb \
    && dpkg -i /tmp/loclx.deb \
    && apt --fix-broken install -y

# Add LocalXpose authentication token
RUN loclx config --token 8jxT6ff9P93gsm1d4bdNYjXPbnSMwfIrFtSWdcAB

# Install Python
RUN apt update && apt install -y python3

# Install OBS Studio
RUN apt update && apt install -y software-properties-common \
    && add-apt-repository ppa:obsproject/obs-studio \
    && apt update && apt install -y obs-studio

# Expose RDP port
EXPOSE 3389

# Expose HTTP server port
EXPOSE 8000

# Start the remote desktop, LocalXpose, OBS, and Python simple HTTP server, ensuring no stale PID file
CMD ["/bin/bash", "-c", "rm -f /var/run/xrdp/xrdp-sesman.pid && loclx tcp 3389 & xrdp-sesman && xrdp --nodaemon & python3 -m http.server 8000"]
