# frozen_string_literal: true

server '${SERVER_NAME}', user: '${USER}',
                         roles: %w[
                           mysql
                           rabbitmq
                           nginx
                           elasticsearch
                           redis
                           swarm_manager
                         ]

set :shared, network: fetch(:network)

set :mysql,
    stack_name: 'mysql',
    mysql_docker_image: 'mysql',
    mysql_docker_image_tag: '5.7',
    mysql_volume: "#{fetch(:deploy_to)}/mysql"

set :rabbitmq,
    stack_name: 'rabbitmq',
    rabbitmq_docker_image: 'rabbitmq',
    rabbitmq_docker_image_tag: '3.6-management',
    rabbitmq_volume: "#{fetch(:deploy_to)}/rabbitmq"

set :nginx,
    stack_name: 'nginx',
    nginx_docker_image: 'nginx',
    nginx_docker_image_tag: 'latest',
    port_http: '80',
    port_https: '443'

set :redis,
    stack_name: 'redis',
    docker_image_prefix: 'docker.io/',
    redis_docker_image: 'redis',
    redis_docker_image_tag: 'latest',
    nfs_mount: "#{fetch(:deploy_to)}/redis",
    port: '6379'

set :elasticsearch,
    stack_name: 'elasticsearch',
    elasticsearch_docker_image: 'elasticsearch',
    elasticsearch_docker_image_tag: '5.4.0-alpine',
    elastic_first_port: '9200',
    elastic_second_port: '9300'

set :errbit,
    stack_name: 'errbit',
    errbit_docker_image: 'docker.io/errbit/errbit',
    errbit_db_docker_image: 'mongo',
    errbit_docker_image_tag: 'latest',
    errbit_db_docker_image_tag: '3.2',
    errbit_host: '${ERRBIT_HOST}',
    errbit_protocol: 'http',
    errbit_port: '80',
    ldap_host: '${LDAP_HOST}',
    ldap_user: '${LDAP_USER}',
    ldap_password: '${LDAP_PASSWORD}',
    http_proxy: '${HTTP_PROXY}',
    https_proxy: '${hTTPS_PROXY}',
    no_proxy: '${NO_PROXY}',
    mongo_volume: "#{fetch(:deploy_to)}/mongo"
