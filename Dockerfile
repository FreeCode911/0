FROM scottyhardy/docker-remote-desktop:latest

# Set the hostname dynamically
ARG HOSTNAME=$(hostname)
ENV HOSTNAME=$HOSTNAME

# Install dependencies and tools
RUN apt update && apt install -y curl unzip python3

# Download and unzip localtonet
RUN curl -L https://localtonet.com/download/localtonet-linux-arm64.zip -o localtonet.zip \
    && unzip localtonet.zip -d /usr/local/bin/ \
    && rm localtonet.zip \
    && chmod 777 /usr/local/bin/localtonet

# Add localtonet authentication token
RUN /usr/local/bin/localtonet authtoken ZM1kBStOzFREqdcJT6KLHbN3hijy82GXo

# Install OBS Studio
RUN apt update && apt install -y software-properties-common \
    && add-apt-repository ppa:obsproject/obs-studio \
    && apt update && apt install -y obs-studio

# Expose RDP port
EXPOSE 3389

# Expose HTTP server port
EXPOSE 8000

# Start the remote desktop, localtonet, OBS, and Python simple HTTP server, ensuring no stale PID file
CMD ["/bin/bash", "-c", "rm -f /var/run/xrdp/xrdp-sesman.pid && /usr/local/bin/localtonet tcp 3389 & xrdp-sesman && xrdp --nodaemon & python3 -m http.server 8000"]
