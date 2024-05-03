# golang build state
FROM golang:1.22-bookworm AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
COPY scripts /app/scripts

## workaround for go mod download failing due to recoverable proxy/cdn/network issues
#RUN go mod download
RUN chmod +x scripts/go-download-retry.sh && ./scripts/go-download-retry.sh

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/customized-pocketbase

# run tests in the container
FROM build-stage AS run-test-stage

WORKDIR /app
RUN go test -v ./...

# use a slim image as base
FROM debian:bookworm-slim AS build-release-stage

WORKDIR /app

COPY --from=build-stage /app/customized-pocketbase /app/customized-pocketbase

# copy public
COPY pb_public/ pb_public/

# if we only create hooks and migrations in dev then copy
COPY pb_migrations/ pb_migrations/
COPY pb_hooks/ pb_hooks/

## add and switch to user
ARG USERNAME=golang
ARG GROUPNAME=golang
ARG USER_UID=1000
ARG USER_GID=1000
RUN set -ex \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && usermod -a -G ${GROUPNAME} ${USERNAME}

# create datapath && chown modifiable pathes to golang user (you should probably instead overlay this with a volume)
RUN mkdir -p /app/pb_data \
    && chown -R golang:golang /app/pb_data

USER ${USERNAME}:${GROUPNAME}

EXPOSE 8090

ENTRYPOINT ["/app/customized-pocketbase"]
