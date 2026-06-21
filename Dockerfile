# Stage 1: Build Flutter Web application
FROM debian:bookworm-slim AS build-env

# Install dependencies needed by Flutter SDK
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone the Flutter SDK matching project version
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b 3.35.1 --depth 1

# Add flutter to path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor to pre-download binaries
RUN flutter doctor -v

# Set up working directory
WORKDIR /app

# Copy dependency configs
COPY pubspec.yaml ./
RUN flutter pub get

# Copy source files
COPY . .

# Build the release web package
RUN flutter build web --release

# Stage 2: Serve web package via Nginx
FROM nginx:alpine-slim

# Copy built web artifacts
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose Nginx port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
