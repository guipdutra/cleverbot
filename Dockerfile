FROM elixir:1.8-alpine

RUN apk update && \
    apk add git build-base inotify-tools nodejs nodejs-npm && \
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force && \
    mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
