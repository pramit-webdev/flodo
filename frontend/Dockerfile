# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Copy project
WORKDIR /app
COPY . .

# Copy project
WORKDIR /app
COPY . .

# Get dependencies and build web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
