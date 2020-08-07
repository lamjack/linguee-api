FROM golang:alpine AS builder
WORKDIR /app

ENV GO111MODULE on
ENV GOPROXY https://goproxy.io

RUN apk add --no-cache git make
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app -v main.go

FROM alpine:latest
WORKDIR /app

RUN apk add --no-cache tzdata ca-certificates
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=builder /app/app ./
EXPOSE 8000
ENTRYPOINT ["./app"]