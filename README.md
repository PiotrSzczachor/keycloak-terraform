# Keycloak + Terraform 

---

## Uruchomienie Keycloaka

### Zainstaluj dockera na swoim komputerze (może być docker desktop)

### Z lokalizacji keycloak-terraform wykonaj

```docker-compose up -d```

### Po wykonaniu powyższej komendy i odpaleniu docker desktop powinien się tam wyświetlić kontener keycloak-terraform

---

## Automatyczna konfiguracja keycloaka z użyciem terraform

### Zainicjalizuj terraform

```docker compose run --rm terraform init```

### Zaplanuj zmiany

```docker compose run --rm terraform plan```

### Zaaplikuj zmiany

```docker compose run --rm terraform apply -auto-approve```

