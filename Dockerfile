# Use Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install dependencies
RUN apt update && apt install -y \
    software-properties-common curl unzip \
    xvfb x11vnc python3 python3-pip \
    xrdp xfce4 xfce4-terminal \
    obs-studio && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Create XRDP user
RUN useradd -m -s /bin/bash obsuser && echo "obsuser:password" | chpasswd

# Configure XRDP
RUN echo "xfce4-session" > /home/obsuser/.xsession && \
    chown obsuser:obsuser /home/obsuser/.xsession && \
    echo "exec startxfce4" >> /etc/xrdp/startwm.sh

# Create directory for HTTP server
RUN mkdir -p /var/www

# Create startup script
RUN echo '#!/bin/bash\n\
echo "Starting XRDP..."\n\
service xrdp start\n\
echo "Starting Cloudflare Tunnel..."\n\
cloudflared tunnel --no-autoupdate run --token eyJhIjoiODZiZDAxODBhODRlYThiZDQ5MDIwOWRmODM4MmRmZWMiLCJ0IjoiNzczYzBlMjQtYzVkMy00MDQzLWE5YmYtNGYxMzM3ZGQ1MTM3IiwicyI6Ik5ETTNaR0V3TW1JdE5tTTNaQzAwWVRCaUxXSTNOamt0WlRFM016Y3lZekZtTmpJMSJ9 &\n\
CLOUDFLARE_PID=$!\n\
echo "Cloudflare Tunnel started (PID: $CLOUDFLARE_PID)."\n\
echo "Starting Simple HTTP Server on port 8080..."\n\
cd /var/www && python3 -m http.server 8080 &\n\
HTTP_SERVER_PID=$!\n\
echo "Python HTTP Server started (PID: $HTTP_SERVER_PID)."\n\
wait $CLOUDFLARE_PID $HTTP_SERVER_PID' > /usr/local/bin/start-all && \
    chmod +x /usr/local/bin/start-all

# Expose necessary ports
EXPOSE 8080 3389

# Run startup script
CMD ["/usr/local/bin/start-all"]
