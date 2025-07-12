# Multi-stage Dockerfile for VibeErrors Rails Engine
# Stage 1: Build environment
FROM ruby:3.3-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    nodejs \
    npm \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy gemspec and Gemfile
COPY vibe_errors.gemspec Gemfile* ./
COPY lib/vibe_errors/version.rb lib/vibe_errors/version.rb

# Install Ruby dependencies
RUN bundle config set --local deployment true && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Stage 2: Runtime environment
FROM ruby:3.3-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd -g 1000 app && \
    useradd -u 1000 -g app -m app

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=app:app /app .
COPY --from=builder --chown=app:app /usr/local/bundle /usr/local/bundle

# Switch to app user
USER app

# Set environment variables
ENV RAILS_ENV=production
ENV RACK_ENV=production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/vibe_errors/health || exit 1

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]