# GridLAB-D Dockerized Project

This project provides a Dockerized environment for **GridLAB-D**, enabling the simulation and logging of power grid models. The project includes:

1. **A multi-stage Dockerfile** for building a lightweight, customizable container.
2. **A GitHub Actions workflow** to automate the creation and publishing of Docker images to **GitHub Container Registry (GHCR)** upon tagging a commit.

## Features

- Multi-stage Dockerfile to build a base image for GridLAB-D and a custom image with an execution entrypoint.
- Automatic logging of simulation events and outputs.
- Customizable simulation paths and logging structure.
- GitHub Actions integration for automated image builds and registry pushes.

---

## Project Structure

### Dockerfile

The `Dockerfile` uses multi-stage builds:

- **Stage 1**: Builds the base image (`base-gl`) with GridLAB-D installed.
- **Stage 2**: Adds a custom entrypoint script to the base image for running simulations.

### Entrypoint Script

The `entrypoint.sh` script is designed to:

- Set up simulation paths and log directories.
- Check for the presence of a simulation model file.
- Execute GridLAB-D simulations while redirecting logs.
- Log simulation events (start, success, or failure).

```bash
#!/bin/bash

# Define paths
MODEL_PATH="/simulation/models/model.glm"
LOGS_DIR="/simulation/outputs"
LOG_FILE="$LOGS_DIR/simulation.log"

# Create directory structure
mkdir -p "$LOGS_DIR"

# Function to log events
log_event() {
    local EVENT=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $EVENT" >> "$LOG_FILE"
}

# Log simulation start
log_event "simulation_starting"

if [ ! -f "$MODEL_PATH" ]; then
    log_event "simulation_failed - Model file not found at $MODEL_PATH"
    echo "Error: Model not found at $MODEL_PATH." >> "$LOGS_DIR/errors.log"
    exit 1
fi

log_event "simulation_started"

if gridlabd \
    --output=JSON \
    --profile=CSV \
    --redirect output:"$LOGS_DIR/output.log" \
    --redirect error:"$LOGS_DIR/errors.log" \
    "$MODEL_PATH" -o "$LOGS_DIR/results"; then
    log_event "simulation_ended - Simulation completed successfully"
else
    log_event "simulation_failed - Simulation encountered an error"
    exit 1
fi
```

---

## GitHub Actions Workflow

A GitHub Actions workflow automates the build and push process to **GitHub Container Registry (GHCR)**. The workflow triggers when a tag is pushed to the repository.

### Workflow File: `.github/workflows/docker-build.yml`

```yaml
name: Build and Push Docker Image to GHCR

on:
  push:
    tags:
      - '*'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: custom-gl

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    # Log in to GitHub Container Registry
    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    # Build and push the Docker image
    - name: Build and push Docker image
      id: push
      uses: docker/build-push-action@v5
      with:
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

```

### Key Points:

- **Triggers on tags**: The workflow runs whenever a tag is pushed to the repository.
- **GHCR Authentication**: Utilizes the default `GITHUB_TOKEN` for authentication with the registry.
- **Image Tags**: Generates `latest` and version-specific tags (e.g., `v1.0.0`).

## License
This project is licensed under the [MIT License](LICENSE).

