# GridLAB-D Dockerized Project

This project provides a Dockerized environment for **GridLAB-D**, enabling the simulation and logging of power grid models. The project includes:

1. **A multi-stage Dockerfile** for building a lightweight, customizable container.
2. **A GitHub Actions workflow** to automate the creation and publishing of Docker images to **GitHub Container Registry (GHCR)** upon tagging a commit.

## Features

- Multi-stage Dockerfile to build a base image for GridLAB-D and a custom image with an execution entrypoint.
- Automatic logging of simulation events and outputs.
- Customizable simulation paths and logging structure.
- GitHub Actions integration for automated image builds and registry pushes.

## Project Structure

### Dockerfile

The `Dockerfile` uses multi-stage builds:

- **Stage 1**: Builds the base image (`base-gl`) with GridLAB-D installed.
- **Stage 2**: Adds a custom entrypoint script to the base image for running simulations.

### Entrypoint Script

The [entrypoint.sh](./entrypoint.sh) script is designed to:

- Set up simulation paths and log directories.
- Check for the presence of a simulation model file.
- Execute GridLAB-D simulations while redirecting logs.
- Log simulation events (start, success, or failure).

## GitHub Actions Workflow

A GitHub Actions workflow automates the build and push process to **GitHub Container Registry (GHCR)**. The workflow triggers when a tag is pushed to the repository.

Workflow File: [.github/workflows/cicd.yml](.github/workflows/cicd.yml)

### Key Points:

- **Triggers on tags**: The workflow runs whenever a tag is pushed to the repository.
- **GHCR Authentication**: Utilizes the default `GITHUB_TOKEN` for authentication with the registry.
- **Image Tags**: Generates `latest` and version-specific tags (e.g., `v1.0.0`).

### Usage

You can use local volume mounts to provide the simulation model file.

The default model file used in the simulation is located at `./simulation/models/model.glm`.

Simulation output directories will be created in `./simulation/outputs`.

```bash
docker run --rm -v ./simulation:/simulation ghcr.io/oalles/custom-gridlabd:latest
```


## License
This project is licensed under the [MIT License](LICENSE).

