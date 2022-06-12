start:
	docker-compose -f $(path_local) up -d
stop:
	docker-compose -f $(path_local) stop
down:
	docker-compose -f $(path_local) down
restart:
	docker-compose -f $(path_local) down
	docker-compose -f $(path_local) up -d
init:
	#cp .env ../backend/.env
	docker-compose -f $(path_local) up -d
	docker-compose -f $(path_local) exec php composer install
	docker-compose -f $(path_local) exec php /src/artisan migrate
	docker exec $(backend) bash -c 'chmod -R 777 /src/storage/logs'
	docker-compose -f $(path_local) exec php /src/artisan config:clear

init-n:
	#cp .env ../backend/.env
	docker-compose -f $(path_local) build --no-cache
	docker-compose -f $(path_local) up -d
	docker-compose -f $(path_local) exec php composer install
	docker-compose -f $(path_local) exec php /src/artisan migrate
	docker exec $(backend) bash -c 'chmod -R 777 /src/storage/logs'
	docker-compose -f $(path_local) exec php /src/artisan config:clear

seed:
	docker-compose -f $(path_local) exec php /src/artisan db:seed

path_local := docker-compose.yml
backend := php
