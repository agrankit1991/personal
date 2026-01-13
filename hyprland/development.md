``` bash
mise use -g java@temurin-21
mise use -g node@lts
mise use -g gradle@latest
```

```bash
install docker docker-compose
sudo systemctl enable --now docker.service
sudo usermod -aG docker $USER // Add your user to the docker group
newgrp docker // apply changes
```

```bash
# Run docker stack
docker compose up -d

# to start the database manually
docker start postgres_dev

# to stop the database
docker stop postgres_dev
```

```bash
# restore backup
cat arthasagar.dump | docker exec -i postgres_dev pg_restore -U "bawandar" -C -c --no-owner -d "postgres"
```
