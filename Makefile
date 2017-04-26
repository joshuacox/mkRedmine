.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs
######################################REDMINIT

all: up

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make up       - build and run docker stack
	@echo ""   1. make down       - shut down docker stack

up: config
	docker-compose up -d

down:
	docker-compose down

rm:
	docker-compose rm

# By default use the examples
# but do not overwrite them after that
config: redmine.env db.env docker-compose.yml

redmine.env:
	cp redmine.env.example redmine.env

db.env:
	cp db.env.example db.env

docker-compose.yml:
	cp docker-compose.yml.example docker-compose.yml

# Aliases
u: up

d: down

h: help

c: config

conf: config

example: config
