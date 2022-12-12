FROM ubuntu:22.04
WORKDIR /app
COPY . .
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y "ppa:kelleyk/emacs" && \
    # Skip apt repo validity checks. Sometimes the above expires.
    touch /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'Acquire::Check-Valid-Until no;' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update && \
    apt-get install -y emacs28 && \
    echo `emacs --version`
RUN apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install lunr
RUN apt-get install -y ruby-full && \
    apt-get install -y build-essential ruby-dev && \
    gem install bundler && \
    bundle lock --add-platform x86_64-linux
RUN bundle install
CMD ["/app/build_script.sh"]

# Usage:
# Build tagged container
#   docker build -t lasagna .
# Run container with volume
#   docker run -it --rm -v "$PWD/public":/app/public lasagna
