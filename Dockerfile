FROM scottyhardy/docker-remote-desktop:latest

# Set a static hostname
ENV HOSTNAME=myown

# Set the system hostname
RUN echo "myown" > /etc/hostname && \
    hostnamectl set-hostname myown

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

# Install OBS Studio and its dependencies
RUN apt update && apt install -y \
    libxcb1 \
    libx11-xcb1 \
    libv4l-0 \
    libx264-148 \
    libavformat58 \
    libavcodec58 \
    libavutil56 \
    libswscale5 \
    libpulse0 \
    libjack0 \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libxcomposite1 \
    libxrandr2 \
    libasound2 \
    libcurl4 \
    x11-utils \
    alsa-utils \
    libglib2.0-0 \
    libsndfile1 \
    obs-studio

# Expose RDP port
EXPOSE 3389

# Expose HTTP server port
EXPOSE 8000

# Start the remote desktop, ngrok, OBS Studio, and Python simple HTTP server, ensuring no stale PID file
CMD ["/bin/bash", "-c", "rm -f /var/run/xrdp/xrdp-sesman.pid && ngrok tcp 3389 & xrdp-sesman && xrdp --nodaemon & obs --no-sandbox --startstreaming & python3 -m http.server 8000"]
