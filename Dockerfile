# Stage 1: Build Flutter Web App
FROM debian:bookworm-slim AS builder

# Accept build arguments for Firebase credentials
ARG FIREBASE_API_KEY
ARG FIREBASE_APP_ID
ARG FIREBASE_MESSAGING_SENDER_ID
ARG FIREBASE_PROJECT_ID
ARG FIREBASE_STORAGE_BUCKET
ARG FIREBASE_AUTH_DOMAIN

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

# Create firebase_options.dart with build args
RUN mkdir -p lib && cat > lib/firebase_options.dart << 'DART_EOF'
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ARG_FIREBASE_API_KEY',
    appId: 'ARG_FIREBASE_APP_ID',
    messagingSenderId: 'ARG_FIREBASE_MESSAGING_SENDER_ID',
    projectId: 'ARG_FIREBASE_PROJECT_ID',
    storageBucket: 'ARG_FIREBASE_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ARG_FIREBASE_API_KEY',
    appId: 'ARG_FIREBASE_APP_ID',
    messagingSenderId: 'ARG_FIREBASE_MESSAGING_SENDER_ID',
    projectId: 'ARG_FIREBASE_PROJECT_ID',
    storageBucket: 'ARG_FIREBASE_STORAGE_BUCKET',
    iosBundleId: 'com.example.societyCrm',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'ARG_FIREBASE_API_KEY',
    appId: 'ARG_FIREBASE_APP_ID',
    messagingSenderId: 'ARG_FIREBASE_MESSAGING_SENDER_ID',
    projectId: 'ARG_FIREBASE_PROJECT_ID',
    storageBucket: 'ARG_FIREBASE_STORAGE_BUCKET',
    authDomain: 'ARG_FIREBASE_AUTH_DOMAIN',
  );
}
DART_EOF

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
