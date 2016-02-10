.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs
######################################REDMINIT

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: builddocker

init: DB_PASS NAME PORT rmall runpostgresinit runredisinit runredminit

externinit: externaldbinfo DB_HOST DB_ADAPTER DB_NAME DB_USER DB_PASS NAME PORT rmall runredisinit externrunredminit

externrun: DB_HOST DB_ADAPTER DB_NAME DB_USER DB_PASS NAME PORT rmall runredis externrunredme

run: DB_PASS NAME PORT rm runpostgres runredis runredmine

runbuild: builddocker runpostgres runredis runredminit

runredisinit:
	$(eval NAME := $(shell cat NAME))
	docker run --name $(NAME)-redis-init \
	-d \
	--cidfile="redisinitCID" \
	redis \
	redis-server --appendonly yes

runpostgresinit:
	$(eval NAME := $(shell cat NAME))
	$(eval DB_PASS := $(shell cat DB_PASS))
	docker run \
	--name=$(NAME)-postgresql-init \
	-d \
	--env='DB_NAME=redmine_production' \
	--cidfile="postgresinitCID" \
	--env='DB_USER=redmine' --env="DB_PASS=$(DB_PASS)" \
	sameersbn/postgresql:9.4

externrunredminit:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval DB_HOST := $(shell cat DB_HOST))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_ADAPTER := $(shell cat DB_ADAPTER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	docker run --name=$(NAME) \
	-d \
	--publish=$(PORT):80 \
	--link=$(NAME)-redis-init:redis \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--env="DB_NAME=$(DB_NAME)" \
	--env="DB_HOST=$(DB_HOST)" \
	--env="DB_USER=$(DB_USER)" \
	--env="DB_ADAPTER=$(DB_ADAPTER)" \
	--env="DB_PASS=$(DB_PASS)" \
	--cidfile="redmineinitCID" \
	sameersbn/redmine

runredminit:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-postgresql-init:postgresql \
	--link=$(NAME)-redis-init:redis \
	--publish=$(PORT):80 \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--cidfile="redmineinitCID" \
	sameersbn/redmine

#	sameersbn/redmine:2.6-latest
# used to be last line above --> 	-t joshuacox/redminit
#--publish=$(PORT):80 \

runredis:
	$(eval NAME := $(shell cat NAME))
	$(eval REDIS_DATADIR := $(shell cat REDIS_DATADIR))
	docker run --name $(NAME)-redis \
	-d \
	--cidfile="redisCID" \
	--volume=$(REDIS_DATADIR):/data \
	redis \
	redis-server --appendonly yes

runpostgres:
	$(eval NAME := $(shell cat NAME))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval POSTGRES_DATADIR := $(shell cat POSTGRES_DATADIR))
	docker run \
	--name=$(NAME)-postgresql \
	-d \
	--env='DB_NAME=redmine_production' \
	--cidfile="postgresCID" \
	--env='DB_USER=redmine' --env="DB_PASS=$(DB_PASS)" \
	--volume=$(POSTGRES_DATADIR):/var/lib/postgresql \
	sameersbn/postgresql:9.4

externrunredmine:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval REDMINE_DATADIR := $(shell cat REDMINE_DATADIR))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval DB_HOST := $(shell cat DB_HOST))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_ADAPTER := $(shell cat DB_ADAPTER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-redis:redis \
	--publish=$(PORT):80 \
	--env="DB_NAME=$(DB_NAME)" \
	--env="DB_HOST=$(DB_HOST)" \
	--env="DB_USER=$(DB_USER)" \
	--env="DB_ADAPTER=$(DB_ADAPTER)" \
	--env="DB_PASS=$(DB_PASS)" \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--volume=$(REDMINE_DATADIR):/data \
	--cidfile="redmineCID" \
	sameersbn/redmine

runredmine:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval REDMINE_DATADIR := $(shell cat REDMINE_DATADIR))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-postgresql:postgresql \
	--link=$(NAME)-redis:redis \
	--publish=$(PORT):80 \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--volume=$(REDMINE_DATADIR):/data \
	--cidfile="redmineCID" \
	sameersbn/redmine

builddocker:
	/usr/bin/time -v docker build -t joshuacox/redminit .

kill:
	-@docker kill `cat redmineCID`
	-@docker kill `cat postgresCID`
	-@docker kill `cat redisCID`

killinit:
	-@docker kill `cat redmineinitCID`
	-@docker kill `cat postgresinitCID`
	-@docker kill `cat redisinitCID`

rm-redimage:
	-@docker rm `cat redmineCID`

rm-initimage:
	-@docker rm `cat redmineinitCID`
	-@docker rm `cat postgresinitCID`
	-@docker rm `cat redisinitCID`

rm-image:
	-@docker rm `cat redmineCID`
	-@docker rm `cat postgresCID`
	-@docker rm `cat redisCID`

rm-redcids:
	-@rm redmineCID

rm-initcids:
	-@rm redmineinitCID
	-@rm postgresinitCID
	-@rm redisinitCID

rm-cids:
	-@rm redmineCID
	-@rm postgresCID
	-@rm redisCID

rmall: kill rm-image rm-cids

rm: kill rm-redimage rm-redcids

rminit: killinit rm-initimage rm-initcids

clean:  rm

initenter:
	docker exec -i -t `cat redmineinitCID` /bin/bash

enter:
	docker exec -i -t `cat redmineCID` /bin/bash

pgenter:
	docker exec -i -t `cat postgresCID` /bin/bash

grab: grabredminedir grabpostgresdatadir grabredisdatadir

externgrab: grabredminedir grabredisdatadir

grabpostgresdatadir:
	-@mkdir -p datadir/postgresql
	docker cp `cat postgresinitCID`:/var/lib/postgresql  - |sudo tar -C datadir/postgresql/ -pxf -
	echo `pwd`/datadir/postgresql > POSTGRES_DATADIR

grabredminedir:
	-@mkdir -p datadir/redmine
	docker cp `cat redmineinitCID`:/var/www/html  - |sudo tar -C datadir/redmine/ -pxf -
	echo `pwd`/datadir/html > REDMINE_DATADIR

grabredisdatadir:
	-@mkdir -p datadir/redis
	docker cp `cat redisinitCID`:/data  - |sudo tar -C datadir/redis/ -pxf -
	echo `pwd`/datadir/redis > REDIS_DATADIR

logs:
	docker logs -f `cat redmineCID`

initlogs:
	docker logs -f `cat redmineinitCID`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

DB_ADAPTER:
	@while [ -z "$$DB_ADAPTER" ]; do \
		read -r -p "Enter the DB_ADAPTER you wish to associate with this container [DB_ADAPTER]: " DB_ADAPTER; echo "$$DB_ADAPTER">>DB_ADAPTER; cat DB_ADAPTER; \
	done ;

DB_PASS:
	@while [ -z "$$DB_PASS" ]; do \
		read -r -p "Enter the DB_PASS you wish to associate with this container [DB_PASS]: " DB_PASS; echo "$$DB_PASS">>DB_PASS; cat DB_PASS; \
	done ;

DB_NAME:
	@while [ -z "$$DB_NAME" ]; do \
		read -r -p "Enter the DB_NAME you wish to associate with this container [DB_NAME]: " DB_NAME; echo "$$DB_NAME">>DB_NAME; cat DB_NAME; \
	done ;

DB_HOST:
	@while [ -z "$$DB_HOST" ]; do \
		read -r -p "Enter the DB_HOST you wish to associate with this container [DB_HOST]: " DB_HOST; echo "$$DB_HOST">>DB_HOST; cat DB_HOST; \
	done ;

DB_USER:
	@while [ -z "$$DB_USER" ]; do \
		read -r -p "Enter the DB_USER you wish to associate with this container [DB_USER]: " DB_USER; echo "$$DB_USER">>DB_USER; cat DB_USER; \
	done ;

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the port you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;

externaldbinfo:
	-@echo "go here https://github.com/sameersbn/docker-redmine#postgresql to learn about the variable necessary to setup this instance"
	-@sleep 5
