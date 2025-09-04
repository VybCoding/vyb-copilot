# Use an official Node.js runtime as a parent image
FROM node:18-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install only production dependencies
# UPDATED: Changed 'npm ci' to 'npm install' to avoid needing a lockfile.
RUN npm install --omit=dev

# Copy the rest of the application source code
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Define the command to run the application
CMD [ "npm", "start" ]