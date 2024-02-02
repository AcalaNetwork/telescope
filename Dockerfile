FROM node:16-alpine

WORKDIR /app

COPY ./data-porter/package.json ./package.json
RUN yarn install --immutable

COPY ./data-porter .

EXPOSE 3000

USER node

ENTRYPOINT ["yarn"]