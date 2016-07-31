.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs
######################################REDMINIT

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: builddocker

link: linkedmysqlrun

init: SMTP_HOST SMTP_PORT SMTP_PASS SMTP_USER DB_NAME DB_PASS NAME PORT rmall runpostgresinit runredisinit runredminit

mysqlinit: SMTP_HOST SMTP_PORT  SMTP_PASS SMTP_USER DB_NAME DB_USER DB_PASS NAME PORT rmall runmysqlinit mysqlrunredminit

mysqlrun: SMTP_HOST SMTP_PORT  SMTP_PASS SMTP_USER DB_USER DB_NAME DB_PASS NAME PORT rm runmysql mysqlrunredmine

linkedmysqlrun: SMTP_HOST SMTP_PORT  SMTP_PASS SMTP_USER DB_HOST DB_ADAPTER DB_USER DB_NAME DB_PASS NAME PORT rm  linkedmysqlrunredmine

externinit: externaldbinfo SMTP_PASS SMTP_USER  DB_HOST DB_ADAPTER DB_NAME DB_USER DB_PASS NAME PORT rmall runredisinit externrunredminit

externrun: SMTP_HOST SMTP_PORT SMTP_PASS SMTP_USER DB_HOST DB_ADAPTER DB_NAME DB_USER DB_PASS NAME PORT rmall runredis externrunredmine

run: SMTP_HOST SMTP_PORT SMTP_PASS SMTP_USER DB_NAME DB_PASS NAME PORT rm runpostgres runredis runredmine

runbuild: builddocker runpostgres runredis runredminit

runredisinit:
	$(eval NAME := $(shell cat NAME))
	docker run --name $(NAME)-redis-init \
	-d \
	--cidfile="redisinitCID" \
	redis \
	redis-server --appendonly yes

runpostgresinit: postgresinitCID

postgresinitCID:
	$(eval NAME := $(shell cat NAME))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval DB_NAME := $(shell cat DB_NAME))
	docker run \
	--name=$(NAME)-postgresql-init \
	-d \
	--env='DB_NAME=$(DB_NAME)' \
	--cidfile="postgresinitCID" \
	--env='DB_USER=$(DB_USER)' --env="DB_PASS=$(DB_PASS)" \
	sameersbn/postgresql:9.4

runmysqlinit:
	$(eval NAME := $(shell cat NAME))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval DB_NAME := $(shell cat DB_NAME))
	docker run \
	--name=$(NAME)-mysql-init \
	-d \
	--env='DB_NAME=$(DB_NAME)' \
	--cidfile="mysqlinitCID" \
	--env='MYSQL_USER=$(DB_USER)' --env="MYSQL_ROOT_PASSWORD=$(DB_PASS)" \
	--env="MYSQL_PASSWORD=$(DB_PASS)" \
	--env="MYSQL_DATABASE=$(DB_NAME)" \
	mysql:5.6

externrunredminit:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval DB_HOST := $(shell cat DB_HOST))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval SMTP_PORT := $(shell cat SMTP_PORT))
	$(eval SMTP_HOST := $(shell cat SMTP_HOST))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
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
	--env="SMTP_PORT=$(SMTP_PORT)" \
	--env="SMTP_HOST=$(SMTP_HOST)" \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
	--env="DB_ADAPTER=$(DB_ADAPTER)" \
	--env="DB_PASS=$(DB_PASS)" \
	--cidfile="redmineinitCID" \
	sameersbn/redmine

runredminit:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval SMTP_PORT := $(shell cat SMTP_PORT))
	$(eval SMTP_HOST := $(shell cat SMTP_HOST))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-postgresql-init:postgresql \
	--link=$(NAME)-redis-init:redis \
	--publish=$(PORT):80 \
	--env="DB_NAME=$(DB_NAME)" \
	--env="DB_USER=$(DB_USER)" \
	--env="DB_PASS=$(DB_PASS)" \
	--env="REDMINE_PORT=$(PORT)" \
	--env="SMTP_PORT=$(SMTP_PORT)" \
	--env="SMTP_HOST=$(SMTP_HOST)" \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--cidfile="redmineinitCID" \
	sameersbn/redmine

mysqlrunredminit:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	$(eval SMTP_PORT := $(shell cat SMTP_PORT))
	$(eval SMTP_HOST := $(shell cat SMTP_HOST))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-mysql-init:mysql \
	--publish=$(PORT):80 \
	--env="REDMINE_PORT=$(PORT)" \
	--env="SMTP_PORT=$(SMTP_PORT)" \
	--env="SMTP_HOST=$(SMTP_HOST)" \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
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
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval POSTGRES_DATADIR := $(shell cat POSTGRES_DATADIR))
	docker run \
	--name=$(NAME)-postgresql \
	-d \
	--env='DB_NAME=$(DB_NAME)' \
	--cidfile="postgresCID" \
	--env='DB_USER=$(DB_USER)' --env="DB_PASS=$(DB_PASS)" \
	--volume=$(POSTGRES_DATADIR):/var/lib/postgresql \
	sameersbn/postgresql:9.4

runmysql:
	$(eval NAME := $(shell cat NAME))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval MYSQL_DATADIR := $(shell cat MYSQL_DATADIR))
	docker run \
	--name=$(NAME)-mysql \
	-d \
	--env='DB_NAME=$(DB_NAME)' \
	--cidfile="mysqlCID" \
	--env='MYSQL_USER=$(DB_USER)' --env="MYSQL_ROOT_PASSWORD=$(DB_PASS)" \
	--env="MYSQL_PASSWORD=$(DB_PASS)" \
	--volume=$(MYSQL_DATADIR):/var/lib/mysql \
	mysql:5.6

externrunredmine:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval REDMINE_DATADIR := $(shell cat REDMINE_DATADIR))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval DB_HOST := $(shell cat DB_HOST))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_ADAPTER := $(shell cat DB_ADAPTER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-redis:redis \
	--publish=$(PORT):80 \
	--env="DB_NAME=$(DB_NAME)" \
	--env="DB_HOST=$(DB_HOST)" \
	--env="DB_USER=$(DB_USER)" \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
	--env="DB_ADAPTER=$(DB_ADAPTER)" \
	--env="DB_PASS=$(DB_PASS)" \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--volume=$(REDMINE_DATADIR):/home/redmine/data \
	--cidfile="redmineCID" \
	sameersbn/redmine

runredmine:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval REDMINE_DATADIR := $(shell cat REDMINE_DATADIR))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-postgresql:postgresql \
	--link=$(NAME)-redis:redis \
	--publish=$(PORT):80 \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--volume=$(REDMINE_DATADIR):/home/redmine/data \
	--cidfile="redmineCID" \
	sameersbn/redmine

mysqlrunredmine:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval REDMINE_DATADIR := $(shell cat REDMINE_DATADIR))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-mysql:mysql \
	--publish=$(PORT):80 \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
	--env="REDMINE_PORT=$(PORT)" \
	--env='REDIS_URL=redis://redis:6379/12' \
	--volume=$(REDMINE_DATADIR):/home/redmine/data \
	--cidfile="redmineCID" \
	sameersbn/redmine

linkedmysqlrunredmine:
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval REDMINE_DATADIR := $(shell cat REDMINE_DATADIR))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	$(eval DB_NAME := $(shell cat DB_NAME))
	$(eval DB_HOST := $(shell cat DB_HOST))
	$(eval DB_USER := $(shell cat DB_USER))
	$(eval DB_ADAPTER := $(shell cat DB_ADAPTER))
	$(eval DB_PASS := $(shell cat DB_PASS))
	docker run --name=$(NAME) \
	-d \
	--link=$(NAME)-mysql:mysql \
	--env="DB_NAME=$(DB_NAME)" \
	--env="DB_HOST=$(DB_HOST)" \
	--env="DB_USER=$(DB_USER)" \
	--env="SMTP_PASS=$(SMTP_PASS)" \
	--env="SMTP_USER=$(SMTP_USER)" \
	--env="DB_ADAPTER=$(DB_ADAPTER)" \
	--env="DB_PASS=$(DB_PASS)" \
	--env="REDMINE_PORT=$(PORT)" \
	--publish=$(PORT):80 \
	--volume=$(REDMINE_DATADIR):/home/redmine/data \
	--cidfile="redmineCID" \
	sameersbn/redmine

builddocker:
	/usr/bin/time -v docker build -t joshuacox/redminit .

kill:
	-@docker kill `cat redmineCID`
	-@docker kill `cat mysqlCID`
	-@docker kill `cat postgresCID`
	-@docker kill `cat redisCID`

killinit:
	-@docker kill `cat redmineinitCID`
	-@docker kill `cat mysqlinitCID`
	-@docker kill `cat postgresinitCID`
	-@docker kill `cat redisinitCID`

rm-redimage:
	-@docker rm `cat redmineCID`

rm-initimage:
	-@docker rm `cat redmineinitCID`
	-@docker rm `cat mysqlinitCID`
	-@docker rm `cat postgresinitCID`
	-@docker rm `cat redisinitCID`

rm-image:
	-@docker rm `cat redmineCID`
	-@docker rm `cat mysqlCID`
	-@docker rm `cat postgresCID`
	-@docker rm `cat redisCID`

rm-redcids:
	-@rm redmineCID

rm-initcids:
	-@rm redmineinitCID
	-@rm mysqlinitCID
	-@rm postgresinitCID
	-@rm redisinitCID

rm-cids:
	-@rm redmineCID
	-@rm mysqlCID
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

mysqlgrab: grabredminedir grabmysqldatadir

externgrab: grabredminedir grabredisdatadir

grabpostgresdatadir:
	-@mkdir -p datadir/postgresql
	docker cp `cat postgresinitCID`:/var/lib/postgresql  - |sudo tar -C datadir/postgresql/ -pxf -
	echo `pwd`/datadir/postgresql > POSTGRES_DATADIR

grabmysqldatadir:
	-@mkdir -p datadir/mysql
	docker cp `cat mysqlinitCID`:/var/lib/mysql  - |sudo tar -C datadir/ -pxf -
	echo `pwd`/datadir/mysql > MYSQL_DATADIR

grabredminedir:
	-@mkdir -p datadir/redmine
	docker cp `cat redmineinitCID`:/home/redmine/data  - |sudo tar -C datadir/redmine/ -pxf -
	echo `pwd`/datadir/redmine/data > REDMINE_DATADIR

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

SMTP_PORT:
	@while [ -z "$$SMTP_PORT" ]; do \
		read -r -p "Enter the SMTP_PORT you wish to associate with this container [SMTP_PORT]: " SMTP_PORT; echo "$$SMTP_PORT">>SMTP_PORT; cat SMTP_PORT; \
	done ;

SMTP_HOST:
	@while [ -z "$$SMTP_HOST" ]; do \
		read -r -p "Enter the SMTP_HOST you wish to associate with this container [SMTP_HOST]: " SMTP_HOST; echo "$$SMTP_HOST">>SMTP_HOST; cat SMTP_HOST; \
	done ;

SMTP_PASS:
	@while [ -z "$$SMTP_PASS" ]; do \
		read -r -p "Enter the SMTP_PASS you wish to associate with this container [SMTP_PASS]: " SMTP_PASS; echo "$$SMTP_PASS">>SMTP_PASS; cat SMTP_PASS; \
	done ;

SMTP_USER:
	@while [ -z "$$SMTP_USER" ]; do \
		read -r -p "Enter the SMTP_USER you wish to associate with this container [SMTP_USER]: " SMTP_USER; echo "$$SMTP_USER">>SMTP_USER; cat SMTP_USER; \
	done ;

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the port you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;

externaldbinfo:
	-@echo "go here https://github.com/sameersbn/docker-redmine#postgresql to learn about the variables necessary to setup this instance"
	-@sleep 5

executeEmailRakeTask:
	@bash emailRakeTask

emailRakeTask:
	$(eval NAME := $(shell cat NAME))
	$(eval SMTP_PASS := $(shell cat SMTP_PASS))
	$(eval SMTP_USER := $(shell cat SMTP_USER))
	echo "docker exec -it $(NAME) sudo -u redmine -H bundle exec rake redmine:email:receive_imap RAILS_ENV="production" host=imap.gmail.com port=993 ssl=true username=$(SMTP_USER) password=$(SMTP_PASS)  folder=Inbox move_on_success=SUCCESS move_on_failure=failed project=contact tracker=support allow_override=priority,tracker,project no_permission_check=1 no_account_notice=1">emailRakeTask
	chmod +x emailRakeTask

checkEmail: emailRakeTask executeEmailRakeTask

