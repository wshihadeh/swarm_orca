# Orca
- A Template project for deploying services to a docker swarm cluster. This template includes the deployment stakes for the following services.

  * Elasticsearch
  * Errbit
  * Nginx
  * RabbitMQ
  * Redis
  * MySql

# Directories & Files Structure
   - application_stack :
     a folder that contains docker-comppose templates files for applications.
  - Capistrano:
    Capistrano gem home folder
  - capistrano/config/deploy/template_stage.rb:
    Deployment stage template.
  - capistrano/config/deploy
    Organize deployment stages and their configurations.
  - capistrano/config/deploy.rb:
    Define all deployment tasks and functions.
  - capistrano/log: capistrano log folder
  - nginx: nginx docker image configurations
  - redis: redis docker image configurations
  - seeds: contains applications DB seed scripts and data.

# Deployment Steps
  - Prepare your deployment stage file under `config/deploy/${your_stage_name}.rb`. You can duplicate the `template_stage` and replace all the necessary configurations.
  - Upload deployment scripts to the swarm manager server

    ```sh
    cd capistrano
    bundle exec cap ${your_stage_name} deploy:setup
    ```

- Create Databases (assuming that orca have two applications web and backend)

    ```sh
    ➜ cd capistrano
    ➜ cap -T | grep "create.*dbs"
        cap deploy:create_web_dbs
        cap deploy:create_backend_dbs
    ```

- Seed Databases (assuming that orca have two applications web and backend)

    ```sh
    ➜ cd capistrano
    ➜ cap -T | grep "seed.*dbs"
        cap deploy:seed_web_dbs
        cap deploy:seed_backend_dbs
    ```

- Create and seed all databases at once

    ```sh
    ➜ cd capistrano
    ➜ cap deploy:all_dbs
    ```

- Deploy services/applications individually

  ```sh
  cd capistrano
  bundle exec cap ${your_stage_name} deploy:${service_name}
  ```

- Deploy all services

  ```sh
  cd capistrano
  bundle exec cap ${your_stage_name} deploy:all
  ```

- Deploy subset of the defined services
  ```
  export DEPLOYED_STACKS='nginx redis'
  export FORK=wshihadeh
  bundle exec cap ${stage} deploy:auto
  ```

- Check Stage status

  ```
  bundle exec cap ${your_stage_name} docker:deploy:info
  ```


- Stop a given stack

  ```
  bundle exec cap ${your_stage_name} docker:stop:${service_name}
  ```
