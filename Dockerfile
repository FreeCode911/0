# Use Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install dependencies
RUN apt update && apt install -y \
    software-properties-common curl unzip \
    xvfb x11vnc python3 python3-pip && \
    add-apt-repository -y ppa:obsproject/obs-studio && \
    apt update && apt install -y obs-studio && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Create directory for HTTP server
RUN mkdir -p /var/www

# Create startup script
RUN echo '#!/bin/bash\n\
echo "Starting Xvfb (Virtual Display)..."\n\
Xvfb :99 -screen 0 1920x1080x24 &\n\
sleep 2\n\
echo "Checking OBS installation..."\n\
if ! command -v obs &> /dev/null; then\n\
    echo "OBS is not installed! Exiting..."\n\
    exit 1\n\
fi\n\
echo "Starting OBS Studio..."\n\
obs --startvirtualcam &\n\
OBS_PID=$!\n\
echo "OBS Studio started (PID: $OBS_PID)."\n\
echo "Starting Cloudflare Tunnel..."\n\
cloudflared tunnel --no-autoupdate run --token eyJhIjoiODZiZDAxODBhODRlYThiZDQ5MDIwOWRmODM4MmRmZWMiLCJ0IjoiNzczYzBlMjQtYzVkMy00MDQzLWE5YmYtNGYxMzM3ZGQ1MTM3IiwicyI6Ik5ETTNaR0V3TW1JdE5tTTNaQzAwWVRCaUxXSTNOamt0WlRFM016Y3lZekZtTmpJMSJ9 &\n\
CLOUDFLARE_PID=$!\n\
echo "Cloudflare Tunnel started (PID: $CLOUDFLARE_PID)."\n\
echo "Starting Simple HTTP Server on port 8080..."\n\
cd /var/www && python3 -m http.server 8080 &\n\
HTTP_SERVER_PID=$!\n\
echo "Python HTTP Server started (PID: $HTTP_SERVER_PID)."\n\
wait $OBS_PID $CLOUDFLARE_PID $HTTP_SERVER_PID' > /usr/local/bin/start-all && \
    chmod +x /usr/local/bin/start-all

# Expose HTTP port
EXPOSE 8080

# Run startup script
CMD ["/usr/local/bin/start-all"]
