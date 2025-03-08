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

# Install Ngrok
RUN curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
    | tee /etc/apt/sources.list.d/ngrok.list && \
    apt update && apt install -y ngrok

# Configure Ngrok authentication token (Replace with your actual token)
RUN ngrok config add-authtoken 2u188f0rAEoOF1Km96G6q22KEJ6_6soqrsdpY3ZZGkJek1Bx8

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
echo "Starting Ngrok Tunnel for RDP..."\n\
ngrok tcp 3389 &\n\
NGROK_PID=$!\n\
echo "Ngrok Tunnel started (PID: $NGROK_PID)."\n\
echo "Starting Simple HTTP Server on port 8080..."\n\
cd /var/www && python3 -m http.server 8080 &\n\
HTTP_SERVER_PID=$!\n\
echo "Python HTTP Server started (PID: $HTTP_SERVER_PID)."\n\
wait $NGROK_PID $HTTP_SERVER_PID' > /usr/local/bin/start-all && \
    chmod +x /usr/local/bin/start-all

# Expose necessary ports
EXPOSE 8080 3389

# Run startup script
CMD ["/usr/local/bin/start-all"]
