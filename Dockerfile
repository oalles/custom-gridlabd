# Stage 1: Create the base image
FROM ubuntu:22.04 AS base-gl

# Update and install necessary dependencies
RUN apt-get update && apt-get install -y sudo curl git nano

# Create directory for gridlabd
WORKDIR /app/gridlabd

# Copy necessary content to install gridlabd
COPY . .

# Expose ports
EXPOSE 6266-6299/tcp

# Run gridlabd installation
RUN curl -sL http://install.gridlabd.us/install.sh | sh

# Verify installation
RUN gridlabd --version=all

# Stage 2: Create the final customized image
FROM base-gl AS custom-gl

# Set the working directory
WORKDIR /simulation

# Copy entry script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the script as the entry point
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]