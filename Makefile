#---VARIABLES---------------------------------#
#---DOCKER---#
DOCKER = docker
level ?= 7
DOCKER_RUN = $(DOCKER) run
DOCKER_COMPOSE = docker compose
DOCKER_COMPOSE_UP = $(DOCKER_COMPOSE) up -d
DOCKER_COMPOSE_STOP = $(DOCKER_COMPOSE) stop
DOCKER_COMPOSE_EXEC = $(DOCKER_COMPOSE) exec
DOCKER_COMPOSE_APP = $(DOCKER_COMPOSE) exec app
DOCKER_COMPOSE_CONSOLE = $(DOCKER_COMPOSE) exec app php bin/console
DOCKER_COMPOSE_TEST = $(DOCKER_COMPOSE) exec app php bin/console
DOCKER_COMPOSE_LINT = $(DOCKER_COMPOSE) exec app php bin/console lint:
DOCKER_COMPOSE_DB = $(DOCKER_COMPOSE) exec database
#------------#

#---COMPOSER-#
COMPOSER = composer
COMPOSER_INSTALL = $(COMPOSER) install -o
COMPOSER_UPDATE = $(COMPOSER) update -o
#------------#

#---NPM-----#
NPM = npm
NPM_INSTALL = $(NPM) install --force
NPM_UPDATE = $(NPM) update
NPM_BUILD = $(NPM) run build
NPM_DEV = $(NPM) run dev
NPM_WATCH = $(NPM) run watch
#------------#

#---PHPQA---#
PHPQA = jakzal/phpqa
PHPQA_RUN = $(DOCKER_RUN) --init -it --rm -v $(PWD):/project -w /project $(PHPQA)
#------------#

#---PHPUNIT-#
PHPUNIT =$(DOCKER_COMPOSE_EXEC) -e APP_ENV=test app php bin/phpunit
#------------#
#---------------------------------------------#

## === 🆘  HELP ==================================================
help: ## Show this help.
	@echo "Symfony-And-Docker-Makefile"
	@echo "---------------------------"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
#---------------------------------------------#

## === 🐋  DOCKER ================================================
docker-up: ## Start docker containers.
	$(DOCKER_COMPOSE_UP)
.PHONY: docker-up

docker-stop: ## Stop docker containers.
	$(DOCKER_COMPOSE_STOP)
.PHONY: docker-stop
#---------------------------------------------#

## === 🎛️  SYMFONY ===============================================
sf: ## List and Use All Symfony commands (make sf command="commande-name").
	$(DOCKER_COMPOSE_CONSOLE) $(command)
.PHONY: sf

sf-cc: ## Clear symfony cache.
	$(DOCKER_COMPOSE_CONSOLE) cache:clear
.PHONY: sf-cc

sf-log: ## Show symfony logs.
	$(DOCKER_COMPOSE_CONSOLE) server:log
.PHONY: sf-log

sf-dc: ## Create symfony database.
	$(DOCKER_COMPOSE_CONSOLE) doctrine:database:create --if-not-exists --connection=default
.PHONY: sf-dc

sf-dd: ## Drop symfony database.
	$(DOCKER_COMPOSE_CONSOLE) doctrine:database:drop --if-exists --force --connection=default
.PHONY: sf-dd

sf-su: ## Update symfony schema database.
	$(DOCKER_COMPOSE_CONSOLE) doctrine:schema:update --force
.PHONY: sf-su

sf-mm: ## Make migrations.
	$(DOCKER_COMPOSE_CONSOLE) make:migration
.PHONY: sf-mm

sf-dmm: ## Migrate.
	$(DOCKER_COMPOSE_CONSOLE) doctrine:migrations:migrate --no-interaction
.PHONY: sf-dmm

sf-fixtures: ## Load fixtures.
	$(DOCKER_COMPOSE_CONSOLE) doctrine:fixtures:load --no-interaction
.PHONY: sf-fixtures

sf-me: ## Make symfony entity
	$(DOCKER_COMPOSE_CONSOLE) make:entity
.PHONY: sf-me

sf-mc: ## Make symfony controller
	$(DOCKER_COMPOSE_CONSOLE) make:controller
.PHONY: sf-mc

sf-perm: ## Fix permissions.
	$(DOCKER_COMPOSE_APP) chmod -R 777 var
.PHONY: sf-perm

sf-sudo-perm: ## Fix permissions with sudo.
	$(DOCKER_COMPOSE_APP) sudo chmod -R 777 var
.PHONY: sf-sudo-perm

sf-dump-env: ## Dump env.
	$(SYMFONY_CONSOLE) debug:dotenv
.PHONY: sf-dump-env

sf-dump-env-container: ## Dump Env container.
	$(DOCKER_COMPOSE_CONSOLE) debug:container --env-vars
.PHONY: sf-dump-env-container

sf-dump-routes: ## Dump routes.
	$(DOCKER_COMPOSE_CONSOLE) debug:router
.PHONY: sf-dump-routes
#---------------------------------------------#

## === 📦  COMPOSER ==============================================
composer-install: ## Install composer dependencies.
	$(DOCKER_COMPOSE_APP) $(COMPOSER_INSTALL)
.PHONY: composer-install

composer-update: ## Update composer dependencies.
	$(DOCKER_COMPOSE_APP) $(COMPOSER_UPDATE)
.PHONY: composer-update

composer-validate: ## Validate composer.json file.
	$(DOCKER_COMPOSE_APP) $(COMPOSER) validate
.PHONY: composer-validate

composer-validate-deep: ## Validate composer.json and composer.lock files in strict mode.
	$(DOCKER_COMPOSE_APP) $(COMPOSER) validate --strict --check-lock
.PHONY: composer-validate-deep
#---------------------------------------------#

## === 📦  NPM ===================================================
npm-install: ## Install npm dependencies.
	$(NPM_INSTALL)
.PHONY: npm-install

npm-update: ## Update npm dependencies.
	$(NPM_UPDATE)
.PHONY: npm-update

npm-build: ## Build assets.
	$(NPM_BUILD)
.PHONY: npm-build

npm-dev: ## Build assets in dev mode.
	$(NPM_DEV)
.PHONY: npm-dev

npm-watch: ## Watch assets.
	$(NPM_WATCH)
.PHONY: npm-watch
#---------------------------------------------#

## === 🐛  PHPQA =================================================
qa-cs-fixer-dry-run: ## Run php-cs-fixer in dry-run mode.
	$(PHPQA_RUN) php-cs-fixer fix ./src --config=.php-cs-fixer.dist.php --verbose --dry-run
.PHONY: qa-cs-fixer-dry-run

qa-cs-fixer: ## Run php-cs-fixer.
	$(PHPQA_RUN) php-cs-fixer fix ./src --config=.php-cs-fixer.dist.php --verbose
.PHONY: qa-cs-fixer

qa-phpstan: ## Run phpstan.
	$(PHPQA_RUN) phpstan analyse ./src --level=$(level)
.PHONY: qa-phpstan

qa-phpcpd: ## Run phpcpd (copy/paste detector).
	$(PHPQA_RUN) phpcpd ./src
.PHONY: qa-phpcpd

qa-php-metrics: ## Run php-metrics.
	$(PHPQA_RUN) phpmetrics --report-html=var/phpmetrics ./src
.PHONY: qa-php-metrics

qa-lint-twigs: ## Lint twig files.
	$(DOCKER_COMPOSE_LINT)twig ./templates
.PHONY: qa-lint-twigs

qa-lint-yaml: ## Lint yaml files.
	$(DOCKER_COMPOSE_LINT)yaml ./config
.PHONY: qa-lint-yaml

qa-lint-container: ## Lint container.
	$(DOCKER_COMPOSE_LINT)container
.PHONY: qa-lint-container

qa-lint-schema: ## Lint Doctrine schema.
	$(DOCKER_COMPOSE_CONSOLE) doctrine:schema:validate --skip-sync -vvv --no-interaction
.PHONY: qa-lint-schema

qa-audit: ## Run composer audit.
	$(DOCKER_COMPOSE_APP) $(COMPOSER) audit
.PHONY: qa-audit
#---------------------------------------------#

## === 🔎  TESTS =================================================
tests: ## Run tests.
	$(PHPUNIT) --testdox
.PHONY: tests

tests-coverage: ## Run tests with coverage.
	$(PHPUNIT) --coverage-html var/coverage
.PHONY: tests-coverage
#---------------------------------------------#

## === ⭐  OTHERS =================================================
before-commit: qa-cs-fixer qa-phpstan qa-phpcpd qa-lint-yaml qa-lint-container qa-lint-schema ## Run before commit.
.PHONY: before-commit

first-install: docker-up composer-install sf-perm sf-dc sf-dmm open-app ## First install.
.PHONY: first-install

start: docker-up ## Start project.
.PHONY: start

stop: docker-stop sf-stop ## Stop project.
.PHONY: stop

reset-db: ## Reset database.
	$(eval CONFIRM := $(shell read -p "Are you sure you want to reset the database? [y/N] " CONFIRM && echo $${CONFIRM:-N}))
	@if [ "$(CONFIRM)" = "y" ]; then \
		$(MAKE) sf-dd; \
		$(MAKE) sf-dc; \
		$(MAKE) sf-dmm; \
	fi
.PHONY: reset-db

setup-dev: ## set up dev.
	$(DOCKER_COMPOSE_APP) php bin/console ii:empty-database && $(DOCKER_COMPOSE_APP) php bin/console d:m:m --all-or-nothing -n && $(DOCKER_COMPOSE_UP) && $(DOCKER_COMPOSE_APP) php bin/console ii:l:ma && $(DOCKER_COMPOSE_APP) php bin/console ii:legacy:batch-souscription && $(DOCKER_COMPOSE_APP) php bin/console ii:config-user-dev
.PHONY: setup-dev

app: ## container app.
	$(DOCKER_COMPOSE_APP) sh
.PHONY: app

db: ## container db.
	$(DOCKER_COMPOSE_DB) sh
.PHONY: db

open-app: ## open app.
	open https://api-per.inter-invest.local/docs
.PHONY: open-app

open-mq: ## open rabbitMQ.
	open http://localhost:15672/
.PHONY: open-mq

open-n8n: ## open n8n.
	open http://localhost:5678/
.PHONY: open-n8n
#---------------------------------------------#

#---VARIABLES---------------------------------#
#---DOCKER---#
PASSWORD = $(database)

#---TARGETS---------------------------------#
.PHONY: afficher

login:
	@echo $(PASSWORD)