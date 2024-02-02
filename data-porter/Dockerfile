FROM node:16-alpine

WORKDIR /app

COPY ./package.json ./package.json
COPY ./yarn.lock ./yarn.lock
RUN yarn install --immutable

COPY . .

EXPOSE 3000

USER node

ENTRYPOINT ["yarn"]