ARG  BUILDER_IMAGE=golang:1.20-buster
ARG  DISTROLESS_IMAGE=gcr.io/distroless/base-debian11

############################
# STEP 1 build executable binary
############################
FROM ${BUILDER_IMAGE} as builder

# Ensure ca-certficates are up to date
RUN update-ca-certificates

WORKDIR $GOPATH/src/mypackage/myapp/

# use modules
COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY app/*.go ./

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/hello .

############################
# STEP 2 build a small image
############################
# using base nonroot image
# user:group is nobody:nobody, uid:gid = 65534:65534
FROM ${DISTROLESS_IMAGE}

# Copy our static executable
COPY --from=builder /go/bin/hello /go/bin/hello

EXPOSE 8080

# Run the hello binary.
ENTRYPOINT ["/go/bin/hello"]
