export UID=$(shell id -u)
export GID=$(shell id -g)

.PHONY: up down logs shell wp-cli test phpunit mailpit

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

shell:
	docker compose exec wordpress /bin/bash

wp-cli:
	docker compose run --rm wp-cli wp $(cmd)

test: phpunit

phpunit:
	docker compose run --rm phpunit phpunit -c /var/www/html/wp-content/plugins/your-plugin/phpunit.xml

mailpit:
	open http://localhost:8025

install:
	docker compose run --rm wp-cli wp core install --path=/var/www/html --url=http://localhost:8000 --title=DevSite --admin_user=admin --admin_password=password --admin_email=admin@example.com

db-export:
	docker compose exec db /usr/bin/mysqldump -u wordpress -pwordpress wordpress > backup.sql

db-import:
	docker compose exec -T db /usr/bin/mysql -u wordpress -pwordpress wordpress < backup.sql

permissions:
	sudo chown -R $(UID):$(GID) src

prune:
	@echo "Pruning Docker volumes and database..."
	docker compose down -v
	rm -rf ./src/*
	@echo "Volumes and database have been deleted."

nuke: prune
	@echo "Nuking Docker images..."
	docker compose down --rmi all
	@echo "Docker images have been deleted."