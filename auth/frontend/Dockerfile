# Use an official Node.js runtime as the base image
FROM node:14-alpine

# Set the working directory inside the container
WORKDIR /auth_frontend

# Copy the package.json and package-lock.json (or yarn.lock) files to the container
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the entire project directory to the container
COPY . .

# Build the React application
RUN npm run build

# Set the environment variable to serve the static files
ENV NODE_ENV=production

# Expose the port on which your React application will run (default is 3000)
EXPOSE 3000

# Define the command to start your application
CMD ["npm", "start"]

