FROM golang:1.22.6-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o url-shortener main.go

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/url-shortener .

EXPOSE 9808

CMD ["./url-shortener"]
