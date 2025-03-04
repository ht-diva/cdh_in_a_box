
TARGETS=start stop


all:
	@echo "Try one of: ${TARGETS}"

start:
	docker-compose up -d

stop:
	docker-compose stop

tag:
	git tag v${VERSION}

