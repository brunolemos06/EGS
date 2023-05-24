reg_port=5432
docker push registry.deti:$reg_port/egs-ridemate/auth_backend:v1
docker push registry.deti:$reg_port/egs-ridemate/auth_frontend:v1
docker push registry.deti:$reg_port/egs-ridemate/chat_api:v1
docker push registry.deti:$reg_port/egs-ridemate/composer:v1
docker push registry.deti:$reg_port/egs-ridemate/payments:v1
docker push registry.deti:$reg_port/egs-ridemate/reviews:v1
docker push registry.deti:$reg_port/egs-ridemate/trip:v1