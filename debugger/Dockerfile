# Derived from debian
FROM golang:1.20.3 AS build-dlv

# Install delve
# Disable CGO so that dlv is statically linked.
# By default, delve is dynamically linked to glibc, but alpine linux uses musl-libc.
RUN CGO_ENABLED=0 go install github.com/go-delve/delve/cmd/dlv@v1.20.2

# Final container
FROM alpine:3.17.2
COPY --from=build-dlv /go/bin/dlv /usr/local/bin/dlv
# Utilities we'll use during the demonstration
RUN apk add \
    binutils \
    elfutils
