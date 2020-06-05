FROM softonic/node-prune AS prune

FROM node:14.3-slim AS build
WORKDIR /app
COPY --from=prune /go/bin/node-prune /usr/local/bin/
ADD . .
RUN npm install --only=prod
RUN node-prune

FROM node:14.3-alpine
ENV NODE_ENV production
ENV PORT 80
WORKDIR /app
COPY --from=build /app .
EXPOSE 80
CMD ["node", "index.js"]
