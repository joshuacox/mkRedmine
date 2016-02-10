# mkRedmine

Make a persistent Redmine docker container

#### usage

Run a base redmine with initial database

```
make init
```

Now `grab` the datadirectories for peristence

```
make grab
```

You can now kill the init instances

```
make rminit
```

And finally run the persistent instances using the data dirs defined, notice 

```
make run
```

Notice that `make grab` creates a directory `datadir` that you should move wherever you like in your filesystem 
, but, if you do, update the three `*DATADIR` files in this directory before you `make run`

```
grep datadir *DATADIR
POSTGRES_DATADIR:/home/thoth/git/mkRedmine/datadir/postgresql
REDIS_DATADIR:/home/thoth/git/mkRedmine/datadir/redis
REDMINE_DATADIR:/home/thoth/git/mkRedmine/datadir/html
```

### External DB

https://github.com/sameersbn/docker-redmine#postgresql to learn about the variable necessary to setup this instance

You should be able to make the container use an external database in this fashion:

```
make externinit
```

Now `grab` the datadirectories for peristence

```
make externgrab
```

You can now kill the init instances

```
make rminit
```

And finally run the persistent instances using the data dirs defined

```
make externrun
```
