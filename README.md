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

And finally run the persistent instances using the data dirs defined

```
make run
```


