ARG STAGE

FROM rust:slim-buster as spotifyd-builder
RUN apt update && \
    apt install -y libasound2-dev libssl-dev libpulse-dev libdbus-1-dev && \
    rm -rf /var/lib/apt/lists/* 
RUN cargo install spotifyd --locked

FROM node:lts-buster-slim as frontend-builder
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install --production
COPY frontend/ ./
RUN npm build

FROM debian:buster-slim as final-prod
RUN apt update && \
    apt install -y nginx && \
    rm -rf /var/lib/apt/lists/*
COPY --from=frontend-builder /frontend/build /usr/share/nginx/html

FROM node:lts-buster-slim as final-dev
WORKDIR /usr/src/frontend
COPY frontend/package*.json ./
RUN npm install

FROM final-${STAGE} as final
RUN apt update && \
    apt install -y libasound2 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=spotifyd-builder /usr/local/cargo/bin/spotifyd /usr/bin
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh .
CMD [ "./entrypoint.sh" ]
