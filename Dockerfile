FROM golang:1.23-alpine AS server_build

WORKDIR /appbuild

ARG GOARCH

COPY go.mod go.sum /appbuild/

COPY ./ /appbuild

RUN CGO_ENABLED=0 GOOS=linux go build -o fritzbox-cloudflare-dyndns

# Build deployable server
FROM ghcr.io/hassio-addons/base:17.0.1

COPY --from=server_build /appbuild/fritzbox-cloudflare-dyndns /
RUN chmod +x /fritzbox-cloudflare-dyndns

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]