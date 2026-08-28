# Image de déploiement du site produit.
#
# Bun est utilisé en deux temps : une étape de construction qui installe les
# dépendances et produit le site statique, puis une image d'exécution qui ne
# contient que le résultat et le serveur. La version de Bun est épinglée à
# l'identique de la CI et du lockfile — un déploiement doit reproduire ce qui
# a été testé, pas ce qui est le plus récent.

# ---------------------------------------------------------------- construction
FROM oven/bun:1.4.0 AS build

WORKDIR /app

# Les dépendances d'abord : cette couche est réutilisée tant que le lockfile
# ne bouge pas, ce qui rend les déploiements suivants nettement plus rapides.
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY tsconfig.json build.ts ./
COPY src ./src
RUN bun run build

# ---------------------------------------------------------------- exécution
FROM oven/bun:1.4.0-slim AS runtime

WORKDIR /app
ENV NODE_ENV=production

COPY --from=build /app/dist ./dist
COPY serve.ts ./serve.ts

# Heroku impose le port par la variable d'environnement PORT ; serve.ts la lit
# déjà. La valeur ci-dessous ne sert qu'à faire tourner l'image en local.
ENV PORT=3000
EXPOSE 3000

# `bun` plutôt qu'un shell : le processus reçoit directement SIGTERM au moment
# où Heroku arrête le dyno, et l'arrêt reste propre.
CMD ["bun", "run", "./serve.ts"]
