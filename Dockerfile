FROM node:16-alpine

WORKDIR /app

COPY ./scripts/package.json ./package.json
RUN yarn install --immutable

COPY ./scripts .

EXPOSE 3000

USER node

ENTRYPOINT ["yarn"]