###############
# Build Stage #
###############
FROM mcncyo/hugo-builder:latest as builder

WORKDIR /src
COPY package.json package-lock.json /src/
RUN npm ci --no-optional --quiet

COPY . /src

ENV HUGO_ENV=production

# Base URL
ARG HUGO_BASEURL=https://computerhacking101.com/
ENV HUGO_BASEURL=${HUGO_BASEURL}

# Module Proxy
ARG HUGO_MODULE_PROXY=
ENV HUGO_MODULE_PROXY=${HUGO_MODULE_PROXY}

# NPM mirrors, such as https://registry.npmmirror.com
ARG NPM_CONFIG_REGISTRY=
ENV NPM_CONFIG_REGISTRY=${NPM_CONFIG_REGISTRY}

# Build site
RUN hugo --gc --enableGitInfo \
    && npm install -g @fullhuman/postcss-purgecss rtlcss \
    && hugo --gc

# Set the fallback 404 page if defaultContentLanguageInSubdir is enabled, please replace the `en` with your default language code.
# RUN cp ./public/en/404.html ./public/404.html

###############
# Final Stage #
###############
FROM nginx:stable-alpine

WORKDIR /app
COPY --from=builder /src/public .

COPY deploy/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY deploy/nginx/nginx.conf /etc/nginx/nginx.conf
