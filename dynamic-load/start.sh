docker build -t dynamic_nginx --no-cache .
docker-compose down
docker-compose up -d