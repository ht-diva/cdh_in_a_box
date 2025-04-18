
TARGETS=start stop


all:
	@echo "Try one of: ${TARGETS}"

clean: stop
	docker system prune -f
	docker volume rm cdh_in_a_box_vault_data
	docker volume rm cdh_in_a_box_minio_data
	docker volume rm cdh_in_a_box_mongodb_data

start: build_vault_init
	docker-compose up -d vault-init
	sleep 5
	docker-compose up -d data-ingest
	sleep 5
	docker compose up -d meta-ingest

stop:
	docker-compose stop

tag:
	git tag v${VERSION}

build_vault_init:
	docker buildx build -t ghcr.io/ht-diva/cdh_in_a_box/vault-init:1524ab vault-init/
