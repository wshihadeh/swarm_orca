# Swarm Orca
This gem includes a set of capistrano recipes used to deploy services and rails applications to a swarm cluster.

## Command Line
### Install

```sh
$~> gem install swarm_orca
```

### Commands

```sh
orca decrypt KEY CIPHER # This Command will decrypt the given cipher
orca encrypt KEY TEXT # This Command will encrypt the given text
orca gen_enc_key # This Command will generate new encryption key
orca help [COMMAND] # Describe available commands or one specific command
orca new ORCA_DIRECTORY_NAME GIT_FORK DOCKER_NETWORK  # This Command will create a new Orca project
```

## Install

Add the following to your `Gemfile`.

```ruby
group :deployment do
  gem 'capistrano'
  gem 'swarm_orca'
end
```

Then run

    $ bundle install

## Usage

- Add the following to your `Capfile`.

```ruby
require "swarm_orca"
```


- Add the following to your `deploy.rb`.

```ruby
require "capistrano/swarm_orca/set_global_config"

set :fork, "${YOUR_FORK_NAME}"
# example

set (:db_apps_stacks_mapping), {
  core: %w(api-backend mobile-backedn),
  frontend: %w(),
}

require "capistrano/swarm_orca/deploy"
require "capistrano/swarm_orca/docker"

```

## Define your services and application
Swarm orca define the managed services and applications in `deploy.rb`.

- service_stacks: array include the services stack names. That do not need custome docker images and do not have a database.
- service_stacks_with_build_image: services that need a custome docker image.
- db_apps_stacks_mapping: stacks for your rails application. keys are the stack names and values are the database application names. For example, the core stack include two database applications. While the frontend have no database application.
```
set (:db_apps_stacks_mapping), {
  core: %w(api-backend mobile-backedn),
  frontend: %w(),
}
```

- elasticsearch_apps: application names that are connected to elasticsearch.

## Define your services and applications configurations
Swarm Orca manage the stacks and application configurations in the stage files under `capistrano/config/deploy`

- each stack must have the `stack_name` to define the stack name.
- docker image , tag and other configs can be configured in the same way. These items depend on the stack file `orca/application_stack` it self and the applications needed by the application.

```
set :mysql,
    stack_name: 'mysql',
    mysql_docker_image: 'mysql',
    mysql_docker_image_tag: '5.7',
    mysql_volume: "#{fetch(:deploy_to)}/mysql"
```

- Special config keys:
  {application}_database_url: Database URL for the rails application.
  docker_image_prefix: docker image prefix(host and namespace)
  {application}_docker_image: Docker image name
  {application}_docker_image_tag: Docker image tag.

## Application Seeds

- Define your application seeds
  - By default Swarm orca gem will execute `rake db:seed` to run the seeds for your defined applications.
  - In Addition, Swarm orca gem support custom seeds. To implement a custom seed in your Orca please follow these instruction.
    - Create a new folder in the root directory and call it "seeds".
    - Add a seed file for each of your application. The file name should follow this schema "${application_name}.rb"
    - Example of seeds for backend application

    ```
    cat seeds/backend.rb
    Rails.application.load_tasks
    Rake::Task['roles:reseed_defaults'].execute
    ```

## Application Database migrations

- Define migrations, seeds and elasticsearch reindex.
  - To be able to execute migrations, seeds and elasticsearch reindex, you need to explicitly define the roles on your stage.
  - Example: our backend stack is using db and elasticsearch

  ```
  server "${server}", user: "deploy", roles: %w{${stack}_db ${stack}_reindex}
  server "${server}", user: "deploy", roles: %w{backend_db backend_reindex}
  ```

## Deployment Strategy
By default capistrano supports only git deployment strategy to support xopy strategy do the following:

- Apply these changes to your `Capfile`
   ```diff
     -require "capistrano/scm/git"
     +scm = ENV.fetch('SCM', 'git')
     +require "capistrano/scm/#{scm}"
     +install_plugin Module.const_get("Capistrano::SCM::#{scm.capitalize}")
   ```
- To deploy with Copy strategy add "SCM=copy" to the command line.
  ```
  SCM=copy bundle exec cap ${stage} deploy:${stack}
  ```

## One Time migrations

- Execute One Time migrations from orca.
  - Orca generate a rake task for executing one time migrations for each of the defined database application.
  - These tasks are defined like the following example.
    ```
    deploy:otm_${application}[${migration_name}]
    # deploy:otm_backend[update_referral_bonus_transactions_text]
    ```
 - The migration task should be defined in the project source code under the name space "one_time_migrations"

## Data migrations
To support data migration for individual applications, do the following.
  - Add a new configuration item with the following pattern "${app_name}_data_migrate" to your stack configurations. The value of the item must be true to switch db:migrate to db:migrate:with_data. See the example below for add migrate with data support to a backend application.

```
set :backend, {
    stack_name: 'backend',
    backend_data_migrate: 'true',
....
  }
```

## ERB templates
- Setup Stacks ERB templates
  - Create an ERB template for each of your stacks. Use the extension "erb" for your stacks.
    - Example : docker-stack-backend.yml.erb
  - Add the following line to deploy.rb
    - set (:docker_erb_templates) { true }
  - Ensure the all container environment variables are double-qouted

## Shared Configuration
- To set shared configurations that are available for all stacks, use the following syntax.
```
  set :shared, {
     global_variable: 'value_123'
  }
```

- To set shared application configurations that are available in all stacks with special key.
Need to create shared application set like:
```
  set :backend_shared, {
     environment_label: "staging",
  }
```
Add special key to include shared application config to application config
```
  set :web_backend {
    include_shared_config: 'backend_shared',
  }
  set :mobile_backend {
    include_shared_config: 'backend_shared',
  }
```

## Local Deployment

- Support Local Deployment with Swarm Orca
 - To Be able to deploy locally with orca, you need to implement the following changes on your orca project.
   - Create a local stage with your configs. See below template.

   ```
     server "${server}", ENV.fetch('USER', '${user}'),
     roles: %w{
       swarm_manager
     }
     set (:deploy_to) { "${deploy_to_path}" }
   ```

     - ${server}: Can be replaced by by "localhost", "127.0.0.1" or any domain that include "local" in it.
     - ${user}: Default it will use the ENV 'USER' value, but if this ENV 'USER' is not defined, you can also defined another/own user.
     - ${deploy_to_path}: the destination deploy to path.
     - You mast include at least  "swarm_manager" role.
  - Example deploying mysql and rabbitMq

  ```
    server "127.0.0.1", ENV.fetch('USER', 'shihadeh'),
    roles: %w{
      mysql
      rabbitmq
      swarm_manager
    }

    set (:deploy_to) { "/Users/shihadeh/ggs" }
    # set the path to the docker command.
    set (:docker_path) { "" }

    set :mysql, {
      stack_name: 'mysql',
      mysql_docker_image: 'mysql',
      mysql_docker_image_tag: '5.7',
    }

    set :rabbitmq, {
      rabbitmq_docker_image: 'rabbitmq',
      stack_name: 'rabbitmq_fr',
      rabbitmq_docker_image_tag: '3.6-management',
      rabbitmq_volume: '/Users/shihadeh/ggs/rmq'
    }
  ```

## Encrypted attribute
To support encrypted configuration do the follwing:

  - Create a new encryption key using orc cli.
  - Use orca cli to encrypt the attributes.
  - set the encrypted attributes (you must prefix the attribute key with 'encrypted_' ie. `encrypted_cs_database_url`). for instance
  ```
  set :backend,
    stack_name: 'backend',
    backend_docker_image: 'backend',
    backend_docker_image_tag: 'develop',
    encrypted_backend_database_url: 'h/UNau5AFvhxDbUkBZbPw6RBJzkTPjIMmWOQ+lQ==',
  ```

  - export the encryption key one the machine where the deployemnt scripts will be executed ie (your local machine or jenkins nodes).

## Swarm Orca Deployment
- Start deployment
  - You can use the following commands to setup and deploy locally

  ```
  # setup and deploy, it will created dbs, and run seeds
  bundle exec cap ${stage} deploy:development_setup
  ```

  - Build custom docker images manually

  ```
  bundle exec cap ${stage} deploy:build_images
  ```

  - Deploy individual stacks

  ```
  bundle exec cap ${stage} deploy:${stack}
  ```

  - Deployment with specific fork

  Swarm orca defines a defult for for deployment. The fork value can be changed by setting the ENV 'FORK'.
  ```
  FORK=${forkName}  bundle exec cap ${stage} deploy:${stack}
  ```
  Example deploying with fork 'shihadeh'
  ```
  FORK=shihadeh bundle exec cap ${stage} deploy:${stack}
  ```

- Deploy more than one stack

  ```
  DEPLOYED_STACKS="mysql rabbitmq" bundle exec cap ${stage} deploy:auto
  ```

- Deploy without building docker images.

```
  BUILD_IMAGE=false bundle exec cap ${stage} deploy:${stack}
```

- Deploy all

  ```
  bundle exec cap ${stage} deploy:all
  ```
  - Recreate DBS for an environment
    Use deploy:recreate_all_dbs task to return an envornment(stage) databases to the initial stage
    Example recreating DBS for an environment(stage)
  ```
  bundle exec cap ${stage} deploy:recreate_all_dbs
  ```

- Deploy Debug Mode
  ```
  ORCA_DEBUG=true bundle exec cap ${stage} ${task}
  ```

- Deployment without cleaning up old docker images.
  - Add the `PRUNE=false` variable to your deployment command.
  ```
    PRUNE=false bundle exec cap local deploy:auto
  ```

## Swarm Orca special roles
  - swarm_manager : Nodes with this command will be used to execute deployment commands. You only need one node this role per stage.
  - swarm_node: Swarm Orca will try to cleanup old images or containers on the nodes with this role.
  - stack: To be able to deploy service X to a given cluster, you must to include the X as a role for a manager node in that cluster.
  - #{stack}_db: This role indeicate where the database migration will be executed.
  - #{stack}_reindex: This role indeicate where the elasticsearch reindexing will be executed.






