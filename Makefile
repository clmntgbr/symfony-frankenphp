# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start down logs sh composer vendor sf cc test

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMP) up --detach

start: build up ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

sh: ## Connect to the FrankenPHP container
	@$(PHP_CONT) sh

bash: ## Connect to the FrankenPHP container via bash so up and down arrows go to previous commands
	@$(PHP_CONT) bash

test: ## Start tests with phpunit, pass the parameter "c=" to add options to phpunit, example: make test c="--group e2e --stop-on-failure"
	@$(eval c ?=)
	@$(DOCKER_COMP) exec -e APP_ENV=test php bin/phpunit $(c)


## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf

env:
	$(COMPOSER) dump-env dev

## Composer install
install:
	$(PHP) composer install

## Composer update
update:
	$(PHP) composer update

fabric: 
	$(SYMFONY) messenger:setup-transports

db: 
	$(SYMFONY) doctrine:database:drop -f --if-exists
	$(SYMFONY) doctrine:database:create
	$(SYMFONY) doctrine:schema:update -f
	$(SYMFONY) hautelook:fixtures:load -n

jwt:
	$(SYMFONY) lexik:jwt:generate-keypair --skip-if-exists

trust-cert:
	@echo "Installing local SSL certificate..."
	@docker cp substream-php:/data/caddy/pki/authorities/local/root.crt /tmp/root.crt
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Detected macOS. Installing certificate..."; \
		sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /tmp/root.crt; \
		echo "Certificate installed successfully!"; \
	elif [ "$$(uname)" = "Linux" ]; then \
		echo "Detected Linux. Installing certificate..."; \
		sudo cp /tmp/root.crt /usr/local/share/ca-certificates/root.crt; \
		sudo update-ca-certificates; \
		echo "Certificate installed successfully!"; \
	elif [ "$$(uname)" = "MINGW64_NT" ] || [ "$$(uname)" = "MINGW32_NT" ]; then \
		echo "Detected Windows. Opening certificate installer..."; \
		certutil -addstore -f "ROOT" /tmp/root.crt; \
		echo "Certificate installed successfully!"; \
	else \
		echo "Unknown operating system. Please install the certificate manually from: /tmp/root.crt"; \
	fi
	@rm /tmp/root.crt

migration:
	$(SYMFONY) make:migration

migrate:
	$(SYMFONY) doctrine:migration:migrate

fixture:
	$(SYMFONY) hautelook:fixtures:load -n

schema:
	$(SYMFONY) doctrine:schema:update -f

regenerate:
	$(SYMFONY) make:entity --regenerate App

entity:
	$(SYMFONY) make:entity

message:
	$(SYMFONY) make:message

command:
	$(SYMFONY) make:command

dotenv:
	$(SYMFONY) debug:dotenv

php-cs-fixer:
	$(PHP_CONT) ./vendor/bin/php-cs-fixer fix src --verbose --diff

php-stan:
	$(PHP_CONT) ./vendor/bin/phpstan analyse src -l $(or $(level), 8) --memory-limit=-1