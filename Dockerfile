FROM golang:1.17-alpine as builder

WORKDIR $GOPATH/src/github.com/toni-moreno/github-actions-test

COPY go.mod go.sum  hello-world.go ./

RUN go mod tidy
RUN go build  hello-world.go


FROM alpine:3.14

LABEL maintainer="Toni Moreno <toni.moreno@gmail.com>"
RUN apk add --no-cache bash


COPY --from=builder /go/src/github.com/toni-moreno/github-actions-test/hello-world  /

ENTRYPOINT [ "/hello-world" ]


