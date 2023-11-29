# Stage 1: Build Stage
FROM node:carbon AS build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production Stage
FROM node:carbon
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/dist ./dist
EXPOSE 8080
CMD [ "npm", "start" ]
