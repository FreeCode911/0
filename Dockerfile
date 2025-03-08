# Use Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt update && apt install -y \
    obs-studio xvfb x11vnc \
    python3 python3-pip \
    curl unzip && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "Starting Xvfb (Virtual Display)..."\n\
Xvfb :99 -screen 0 1920x1080x24 &\n\
export DISPLAY=:99\n\
sleep 2\n\
echo "Starting OBS Studio..."\n\
obs-studio --startvirtualcam &\n\
OBS_PID=$!\n\
echo "OBS Studio started (PID: $OBS_PID)."\n\
echo "Starting Cloudflare Tunnel..."\n\
cloudflared tunnel --no-autoupdate run --token eyJhIjoiODZiZDAxODBhODRlYThiZDQ5MDIwOWRmODM4MmRmZWMiLCJ0IjoiNzczYzBlMjQtYzVkMy00MDQzLWE5YmYtNGYxMzM3ZGQ1MTM3IiwicyI6Ik5ETTNaR0V3TW1JtE5tTTNaQzAwWVRCaUxXSTNOamt0WlRFM016Y3lZekZtTmpJMSJ9 &\n\
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
