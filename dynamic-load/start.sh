docker build -t dockerhub.bmi:5000/dynamic_nginx --no-cache .
docker push dockerhub.bmi:5000/dynamic_nginx
docker-compose down
docker-compose up -d