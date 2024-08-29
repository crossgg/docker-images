FROM golang as builder
WORKDIR /app
RUN git clone --quiet https://github.com/flyingpot/chatgpt-proxy.git /app
#COPY chatgpt-proxy/go.mod chatgpt-proxy/go.sum ./
RUN go mod download
#COPY chatgpt-proxy/. .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .
FROM alpine:latest
COPY --from=builder /app/main /app/main
RUN apk add --no-cache tzdata
ENV TZ=Asia/Shanghai
EXPOSE 8080
CMD ["/app/main"]