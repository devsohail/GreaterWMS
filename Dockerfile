# Backend Dockerfile
FROM --platform=linux/amd64 python:3.8.10-slim AS backend

# Create necessary directories
RUN mkdir -p /GreaterWMS/templates

# Copy requirements and scripts
COPY ./requirements.txt /GreaterWMS/requirements.txt
COPY ./backend_start.sh /GreaterWMS/backend_start.sh

# Set working directory
WORKDIR /GreaterWMS

# Environment variables
ENV port=${port}

# Update and install dependencies
RUN apt-get update --fix-missing && apt-get upgrade -y
RUN apt-get install build-essential -y
RUN apt-get install supervisor -y

# Upgrade pip and install Python dependencies
RUN python3 -m pip install --upgrade pip
RUN pip3 install supervisor
RUN pip3 install -U 'Twisted[tls,http2]'
RUN pip3 install -r requirements.txt
RUN pip3 install daphne

# Ensure the script has execution permissions
RUN chmod +x /GreaterWMS/backend_start.sh

# Set the command to run the start script
CMD ["/GreaterWMS/backend_start.sh"]

# Frontend Dockerfile
FROM --platform=linux/amd64 node:14.19.3-buster-slim AS front

# Copy package.json and scripts
COPY ./templates/package.json /GreaterWMS/templates/package.json
COPY ./web_start.sh /GreaterWMS/templates/web_start.sh

# Environment variables
ENV port=${port}

# Set working directory
WORKDIR /GreaterWMS/templates

# Install npm and yarn
RUN npm install -g npm --force
RUN npm install -g yarn --force
RUN npm install -g @quasar/cli --force
RUN yarn install

# Ensure the script has execution permissions
RUN chmod +x /GreaterWMS/templates/web_start.sh

# Set the entry point to run the start script
ENTRYPOINT ["/GreaterWMS/templates/web_start.sh"]
