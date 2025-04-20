# Use an official Node.js LTS image
FROM node:18-alpine

RUN apk add openssl

# Install pnpm globally (faster than npm/yarn)
RUN npm install -g pnpm typescript

# Set working directory
WORKDIR /app

# Copy package.json and pnpm-lock.yaml (or package-lock.json if using npm)
COPY package.json pnpm-lock.yaml* ./

# Install dependencies using pnpm (or npm if preferred)
RUN pnpm install

# Copy the rest of the application code
COPY . .

# Serve minifed code in prod
ENV NODE_ENV=production

# Set env options
ENV PORT=8181
ENV PEM_CERT=cert/localhost.crt
ENV PEM_KEY=cert/localhost.key
ENV INTERVAL_CLIENT_CHECK=3000
ENV INTERVAL_ROOM_UPDATE=600000

# Make Certs
RUN mkdir cert

RUN openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 \
    -keyout localhost.key -out localhost.crt \
    -subj "/C=US/ST=California/L=San Francisco/O=My Company/OU=IT/CN=localhost"

RUN mv localhost.key localhost.crt ./cert/

# Expose the port your app runs on
EXPOSE 8181 

# Start the app
CMD ["npm", "run", "start" ]