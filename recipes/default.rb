gitroot=node[:git_smart_http][:gitroot]
directory gitroot do
  owner "www-data"
  group "www-data"
  mode "0760"
  recursive true
  action :create
end

passwords_root="#{gitroot}/.passwords"
directory passwords_root do
  owner "www-data"
  group "www-data"
  mode "0760"
  recursive true
  action :create
end


node[:git_smart_http][:repos].each do |reponame, settings|
  if settings[:path].nil?
    node[:git_smart_http][:repos][reponame][:path] = "#{gitroot}/#{reponame}.git"
  end
  authstore_path="#{passwords_root}/#{reponame}"
  File authstore_path do
    action :create_if_missing
    group 'www-data'
    owner 'www-data'
    mode "0640"
  end
  execute "add password" do
    command "htpasswd -b #{authstore_path} '#{node[:git_smart_http][:repos][reponame][:username]}' '#{node[:git_smart_http][:repos][reponame][:password]}'"
    ignore_failure true
    returns 0
    action :run
  end

  unless File.exist?(node[:git_smart_http][:repos][reponame][:path])
    Directory node[:git_smart_http][:repos][reponame][:path] do
      owner "www-data"
      group "www-data"
      mode "0760"
      recursive true
      action :create
    end
    execute "init git" do
      command "git init --bare #{node[:git_smart_http][:repos][reponame][:path]}"
      ignore_failure true
      returns 0
      action :run
    end
    execute "update server info" do
      command "git --git-dir=#{node[:git_smart_http][:repos][reponame][:path]} update-server-info"
      ignore_failure true
      returns 0
      action :run
    end
    execute "chown folder to www-data" do
      command "chown -R www-data:www-data #{node[:git_smart_http][:repos][reponame][:path]}"
      ignore_failure true
      returns 0
      action :run
    end
  end
end

include_recipe "apache2::mod_cgi"


template "/etc/apache2/conf.d/gitsmarthttp_conf.conf" do
  source "git_smart_http_conf.erb"
  variables(
      :repos => node[:git_smart_http][:repos],
      :passwords_root => passwords_root
  )
  notifies :restart, "service[apache2]"
end

service 'apache2'