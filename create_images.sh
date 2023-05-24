#auth_backend
cd auth/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/auth_backend:v1 .

#auth_frontend
cd frontend/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/auth_frontend:v1 .

#chat_api
cd ../../chat_api/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/chat_api:v1 .

#composer
cd ../composer/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/composer:v1 .

#payments
cd ../payments/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/payments:v1 .

#reviews
cd ../reviews/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/reviews:v1 .

#trip
cd ../trip/
docker buildx build --platform linux/amd64 --network=host -t registry.deti:5000/egs-ridemate/trip:v1 .