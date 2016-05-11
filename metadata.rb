name             'raintank_mariadb'
maintainer       'Raintank, Inc.'
maintainer_email 'cookbooks@raintank.io'
license          'Apache 2.0'
description      'Installs/Configures raintank_mariadb'
long_description 'Installs/Configures raintank_mariadb'
version          '0.1.0'

depends 'mariadb', '~> 0.3.0'
depends 'mysql2_chef_gem', '~> 1.0.0'
depends 'database', '~> 4.0.6'
depends 'lvm', '~> 1.3.6'
depends 'raintank_base', '~> 0.1.0'
