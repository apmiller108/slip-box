FROM ruby:3.0
WORKDIR /app
COPY . .
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    wget -q http://emacs.ganneff.de/apt.key -O- | apt-key add && \
    add-apt-repository "deb http://emacs.ganneff.de/ buster main" && \
    apt-get update && \
    apt-get install -y emacs-snapshot && \
    update-alternatives --config emacsclient
RUN apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install lunr
RUN apt-get install -y ruby-full && \
    gem install bundler
RUN bundle install
CMD ["/app/build_script.sh"]

# Usage:
# Build tagged container
#   docker build -t lasagna .
# Run container with volume
#   docker run -it --rm -v "$PWD/public":/app/public lasagna
