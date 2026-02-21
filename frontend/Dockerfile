FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache bash wget

COPY package*.json ./
RUN npm install

COPY . .

RUN mkdir -p /app

EXPOSE 5173

CMD ["sh", "/app/start.sh"]
