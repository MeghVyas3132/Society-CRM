# Stage 1: Build Flutter Web App
FROM debian:bookworm-slim AS builder

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && cd ${FLUTTER_HOME} \
    && git checkout stable \
    && flutter --version \
    && flutter config --enable-web \
    && flutter precache --web

# Allow Flutter to run as root
ENV FLUTTER_ALLOW_ROOT=true

# Set working directory
WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Create firebase_options.dart if it doesn't exist (for Docker builds)
RUN if [ ! -f lib/firebase_options.dart ]; then \
    mkdir -p lib && \
    echo 'import "package:firebase_core/firebase_core.dart" show FirebaseOptions;' > lib/firebase_options.dart && \
    echo 'class DefaultFirebaseOptions {' >> lib/firebase_options.dart && \
    echo '  static FirebaseOptions get currentPlatform => web;' >> lib/firebase_options.dart && \
    echo '  static const web = FirebaseOptions(' >> lib/firebase_options.dart && \
    echo '    apiKey: "PLACEHOLDER",' >> lib/firebase_options.dart && \
    echo '    appId: "PLACEHOLDER",' >> lib/firebase_options.dart && \
    echo '    messagingSenderId: "PLACEHOLDER",' >> lib/firebase_options.dart && \
    echo '    projectId: "PLACEHOLDER",' >> lib/firebase_options.dart && \
    echo '    storageBucket: "PLACEHOLDER",' >> lib/firebase_options.dart && \
    echo '    authDomain: "PLACEHOLDER",' >> lib/firebase_options.dart && \
    echo '  );' >> lib/firebase_options.dart && \
    echo '  static const android = web;' >> lib/firebase_options.dart && \
    echo '  static const ios = web;' >> lib/firebase_options.dart && \
    echo '}' >> lib/firebase_options.dart; \
    fi

# Build the web app
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
