# database related
default[:raintank_mariadb][:create_database] = true
default[:raintank_mariadb][:create_replication_user] = false
default[:raintank_mariadb]['worldping-api'][:db_name] = "worldping-api"
default[:raintank_mariadb]['worldping-api'][:db_user] = "grafana"
default[:raintank_mariadb]['worldping-api'][:db_password] = "grafpass"
default[:raintank_mariadb][:task_server][:db_name] = "task_server"
default[:raintank_mariadb][:task_server][:db_user] = "grafana"
default[:raintank_mariadb][:task_server][:db_password] = "grafpass"
default[:raintank_mariadb][:mysql_disk] = "/dev/sdb"
default[:mariadb][:galera][:cluster_name] = "galera_raintank"
default[:grafana][:db_name] = "grafana"
default[:grafana][:db_user] = "grafana"
default[:grafana][:db_password] = "grafpass"
default[:grafana][:db_port] = 3306
default[:mariadb][:galera][:wsrep_cluster_address] = "gcomm://"
default[:mariadb][:innodb][:options][:innodb_flush_log_at_trx_commit] = 0
default[:mariadb][:replication][:expire_logs_days] = 2
override['mariadb']['galera']['cluster_search_query'] = "tags:mariadb AND chef_environment:#{node.environment} AND mariadb_galera_cluster_name:#{node['mariadb']['galera']['cluster_name']}"
override[:mariadb][:use_default_repository] = true
override[:mariadb][:mysqld][:options][:binlog_format] = "ROW"
override[:mariadb][:innodb][:options][:innodb_autoinc_lock_mode] = 2
override[:mariadb][:galera][:wsrep_sst_method] = 'xtrabackup-v2'
override[:mariadb][:replication][:log_bin] = "binlog"
override[:mariadb][:replication][:log_bin_index] = "# leave log_bin_index undefined"
