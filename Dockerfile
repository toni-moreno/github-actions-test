FROM alpine:3.14

LABEL maintainer="Toni Moreno <toni.moreno@gmail.com>"
RUN apk add --no-cache bash

ENTRYPOINT [ "/bin/bash" ]


