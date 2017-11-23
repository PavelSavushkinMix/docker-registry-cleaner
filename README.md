# Cleaner of private docker registry

> It helps you to keep your registry clean.

### Requires
1. curl
2. jq ([Official page](https://stedolan.github.io/jq/))

> Note: the current script works with [Docker Registry HTTP API v2](https://docs.docker.com/registry/spec/api/)

### Usage
```bash
    
    $ bash registry_cleaner.sh [number_of_saved_version] [host:port_of_registry]

```

### Example

```bash

    $ bash registry_cleaner.sh 2 127.0.0.1:5000

```

> Also, you available to add that script into your week/month cron
