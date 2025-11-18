
TARGETS=start stop clean meta_query export_full_stats export_regions export_snps
.PHONY: start stop clean meta_query export_full_stats export_regions export_snps build_vault_init

all:
	@echo "Try one of: ${TARGETS}"

clean: stop
	docker system prune -f
	docker volume rm cdh_in_a_box_vault_data
	docker volume rm cdh_in_a_box_minio_data
	docker volume rm cdh_in_a_box_mongodb_data
	rm -rf results/*

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

meta_query:
	mkdir -p results/query
	docker run --rm -i -v ./data:/data -v ./results:/results --network cdh_in_a_box_internal_net ghcr.io/ht-diva/gwasstudio:6ff728 \
	gwasstudio \
	 --stdout \
	 --vault-token root \
	 --vault-url http://vault:8200 \
	 --vault-path cdh \
	 meta-query \
	 --search-file /data/search_demo_data.yml \
	 --output-prefix /results/query/demo_query

export_full_stats:
	mkdir -p results/full
	docker run --rm -i -v ./data:/data -v ./results:/results --network cdh_in_a_box_internal_net ghcr.io/ht-diva/gwasstudio:6ff728 \
	gwasstudio \
	 --stdout \
	 --vault-token root \
	 --vault-url http://vault:8200 \
	 --vault-path cdh \
	 export \
	 --uri s3://tiledb/data \
	 --search-file /data/search_demo_data.yml \
	 --output-prefix /results/full/demo_full_stats

export_regions:
	mkdir -p results/regions
	docker run --rm -i -v ./data:/data -v ./results:/results --network cdh_in_a_box_internal_net ghcr.io/ht-diva/gwasstudio:6ff728 \
	gwasstudio \
	 --stdout \
	 --vault-token root \
	 --vault-url http://vault:8200 \
	 --vault-path cdh \
	 export \
	 --get-regions-snps data/regions.bed \
	 --uri s3://tiledb/data \
	 --search-file /data/search_demo_data.yml \
	 --output-prefix /results/regions/demo_regions

export_snps:
	mkdir -p results/snps
	docker run --rm -i -v ./data:/data -v ./results:/results --network cdh_in_a_box_internal_net ghcr.io/ht-diva/gwasstudio:6ff728 \
	gwasstudio \
	 --stdout \
	 --vault-token root \
	 --vault-url http://vault:8200 \
	 --vault-path cdh \
	 export \
	 --get-regions-snps data/snps_list.txt \
	 --uri s3://tiledb/data \
	 --search-file /data/search_demo_data.yml \
	 --output-prefix /results/snps/demo_snps \
	 --output-format csv
