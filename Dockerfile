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
RUN npm run build

FROM node:lts-buster-slim as final-prod
RUN apt update && \
    apt install -y nginx firefox-esr && \
    rm -rf /var/lib/apt/lists/*
COPY --from=frontend-builder /frontend/build /usr/share/nginx/html

FROM frontend-builder as final-dev
RUN npm install

FROM final-${STAGE} as final
WORKDIR /
RUN apt update && \
    apt install -y libasound2 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=spotifyd-builder /usr/local/cargo/bin/spotifyd /usr/bin
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh .
CMD [ "./entrypoint.sh" ]
