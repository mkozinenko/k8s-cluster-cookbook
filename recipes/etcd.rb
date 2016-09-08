#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

case node['platform']
  when 'redhat', 'centos', 'fedora'
    yum_package "etcd"
end

service 'etcd' do
  action :enable
end

directory node['kubernetes']['etcd']['basedir'] do
  owner 'etcd'
  group 'etcd'
  recursive true
end

template '/etc/etcd/etcd.conf' do
  mode '0640'
  source 'etcd-etcd.erb'
  variables(
    etcd_client_name: node['kubernetes']['etcd']['clientname'],
    etcd_base_dir: node['kubernetes']['etcd']['basedir'],
    etcd_client_token: node['kubernetes']['etcd']['token'],
    etcd_client_port: node['kubernetes']['etcd']['clientport'],
    etcd_peer_port: node['kubernetes']['etcd']['peerport'],
    etcd_members: node['kubernetes_cluster']['etcd']['members'],
    etcd_cert_dir: node['kubernetes']['secure']['directory']
  )
  notifies :restart, 'service[etcd]', :immediately
end

include_recipe 'kubernetes-cluster::network'