.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs
######################################REDMINIT

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: builddocker

init: POSTGRES_PASSWD NAME PORT runpostgres runredis runredminit

run: POSTGRES_PASSWD NAME PORT runpostgres runredis runredme

runbuild: builddocker runpostgres runredis runredminit

runredis:
	$(eval NAME := $(shell cat NAME))
	docker run --name $(NAME)-redis \
	-d \
	--cidfile="redisCID" \
	--volume=/srv/docker/redis/data:/data \
	redis \
	redis-server --appendonly yes

runredminit:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-postgresql:postgresql \
	--link=$(NAME)-redis:redis \
	--publish=$(PORT):80 \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--cidfile="redmineCID" \
	sameersbn/redmine

#	sameersbn/redmine:2.6-latest
# used to be last line above --> 	-t joshuacox/redminit

runpostgres:
	$(eval NAME := $(shell cat NAME))
	$(eval POSTGRES_PASSWD := $(shell cat POSTGRES_PASSWD))
	docker run --name=$(NAME)-postgresql -d \
	--env='DB_NAME=redmine_production' \
	--cidfile="postgresCID" \
	--env='DB_USER=redmine' --env="DB_PASS=$(POSTGRES_PASSWD)" \
	--volume=/tmp:/tmp \
	--volume=/srv/docker/redmine/postgresql:/var/lib/postgresql \
	sameersbn/postgresql:9.4

builddocker:
	/usr/bin/time -v docker build -t joshuacox/redminit .

kill:
	-@docker kill `cat redmineCID`
	-@docker kill `cat postgresCID`
	-@docker kill `cat redisCID`

rm-name:
	rm  name

rm-image:
	-@docker rm `cat redmineCID`
	-@docker rm `cat postgresCID`
	-@docker rm `cat redisCID`

rm-cids:
	-@rm redmineCID
	-@rm postgresCID
	-@rm redisCID

rm: kill rm-image rm-cids

clean: rm-name rm

enter:
	docker exec -i -t `cat redminitCID` /bin/bash

pgenter:
	docker exec -i -t `cat postgresCID` /bin/bash

grab: grabredminedir grabpostgresdatadir gredredisdir

grabpostgresdatadir:
	-mkdir -p datadir/postgresql
	docker cp `cat postgresCID`:/var/lib/postgresql  - |sudo tar -C datadir/postgresql/ -pxvf -
	echo `pwd`/datadir/postgresql > POSTGRES_DATADIR

grabredminedir:
	-mkdir -p datadir/redmine
	docker cp `cat cid`:/var/www/html  - |sudo tar -C datadir/redmine/ -pxvf -
	echo `pwd`/datadir/html > REDMINE_DATADIR

grabredisdatadir:
	-mkdir -p datadir/redis
	docker cp `cat redistemp`:/data  - |sudo tar -C datadir/redis/ -pxvf -
	echo `pwd`/datadir/redis > REDIS_DATADIR

logs:
	docker logs -f `cat redmineCID`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

POSTGRES_PASSWD:
	@while [ -z "$$POSTGRES_PASSWD" ]; do \
		read -r -p "Enter the postgres pass you wish to associate with this container [POSTGRES_PASSWD]: " POSTGRES_PASSWD; echo "$$POSTGRES_PASSWD">>POSTGRES_PASSWD; cat POSTGRES_PASSWD; \
	done ;

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the port you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;
