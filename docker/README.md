# Docker Deployment

This directory contains the Docker configuration for the Bilibili Live Danmu Proxy server.

## Prerequisites

- Docker
- Docker Compose

## Usage

1.  Configure `config.properties` in this directory.
2.  Run with Docker Compose:

```bash
cd docker
docker-compose up -d --build
```

## Configuration

The `config.properties` file is mounted into the container at runtime. You can modify it without rebuilding the image.

## Architecture

-   **Build Stage**: Uses `dart:stable` to compile the application. The entire workspace is copied to resolve local package dependencies.
-   **Runtime Stage**: Uses `debian:stable-slim` for a small footprint. Only the compiled executable and config file are present.
