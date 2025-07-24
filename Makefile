#!/usr/bin/env bash

include .env
export $(shell sed 's/=.*//' .env)

DOCKER_COMPOSE = docker compose -p $(PROJECT_NAME)

CONTAINER_PHP := $(shell docker container ls -f "name=$(PROJECT_NAME)-php" -q)
CONTAINER_DB := $(shell docker container ls -f "name=$(PROJECT_NAME)-database" -q)
CONTAINER_QA := $(shell docker container ls -f "name=$(PROJECT_NAME)-qa" -q)

PHP := docker exec -ti $(CONTAINER_PHP)
DATABASE := docker exec -ti $(CONTAINER_DB)
QA := docker exec -ti $(CONTAINER_QA)

## Kill all containers
kill:
	@$(DOCKER_COMPOSE) kill $(CONTAINER) || true

## Build containers
build:
	@$(DOCKER_COMPOSE) build --pull --no-cache

## Init project
init: install update

## Start containers
start:
	@$(DOCKER_COMPOSE) up -d

## Stop containers
stop:
	@$(DOCKER_COMPOSE) down

restart: stop start

## Init project
init: install update npm fabric db

npm: 
	$(PHP) npm install
	$(PHP) npm run build

cache:
	$(PHP) rm -r var/cache

## Entering php shell
php:
	@$(DOCKER_COMPOSE) exec php sh

## Entering database shell
database:
	@$(DOCKER_COMPOSE) exec database sh

## Composer install
install:
	$(PHP) composer install

## Composer update
update:
	$(PHP) composer update

fabric: 
	$(PHP) php bin/console messenger:setup-transports

db: 
	$(PHP) php bin/console doctrine:database:drop -f --if-exists
	$(PHP) php bin/console doctrine:database:create
	$(PHP) php bin/console doctrine:schema:update -f
	$(PHP) php bin/console hautelook:fixtures:load -n

jwt:
	$(PHP) php bin/console lexik:jwt:generate-keypair --skip-if-exists
migration:
	$(PHP) php bin/console make:migration

migrate:
	$(PHP) php bin/console doctrine:migration:migrate

fixture:
	$(PHP) php bin/console hautelook:fixtures:load -n

schema:
	$(PHP) php bin/console doctrine:schema:update -f

regenerate:
	$(PHP) php bin/console make:entity --regenerate App

entity:
	$(PHP) php bin/console make:entity

message:
	$(PHP) php bin/console make:message

command:
	$(PHP) php bin/console make:command

dotenv:
	$(PHP) php bin/console debug:dotenv

php-cs-fixer:
	$(QA) ./php-cs-fixer fix src --rules=@Symfony --verbose --diff

php-stan:
	$(PHP) ./vendor/bin/phpstan analyse src -l $(or $(level), 8) --memory-limit=-1

consume:
	$(PHP) php bin/console messenger:consume async-high async-medium async-low -vv

ngrok: 
	ngrok http --url=choice-pretty-leech.ngrok-free.app --host-header=localhost https://localhost:443