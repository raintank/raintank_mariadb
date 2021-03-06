#
# Cookbook Name:: chef_mariadb
# Recipe:: disks
#
# Copyright (C) 2016 Raintank, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

group "mysql" do
  system true
  action :create
end
user "mysql" do
  system true
  gid 'mysql'
  home '/var/lib/mysql'
  action :create
end
directory "/var/lib/mysql" do
  owner "mysql"
  group "mysql"
  mode "0755"
  action :create
end

unless node[:chef_base][:is_img_build]
  include_recipe "lvm"
  include_recipe "chef_base::lvm_attrs"
  lvm_volume_group 'mysql00' do
    physical_volumes [ node['chef_mariadb']['mysql_disk'] ]

    logical_volume 'mysql' do
      size        '100%VG'
      filesystem  node["chef_mariadb"]["fs"]["fs_type"]
      filesystem_params node["chef_mariadb"]["fs_params"]
      stripes     1
    end
  end
  mount '/var/lib/mysql' do
    device '/dev/mapper/mysql00-mysql'
    fstype node["chef_mariadb"]["fs"]["fs_type"]
    options node["chef_mariadb"]["fs"]["fs_opts"]
    action [ :mount, :enable]
  end
end
