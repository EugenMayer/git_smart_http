Cookbook for deploying smart-http git configurations
===========

* support multiple repos with different auth-files
* calls git hooks properly
* supports repos defined by other reciepes
* support multiple auth
* user/password can be set for each repo using chef (else auto-generated)
* configureable domain / git-root path
* ssl support

Dependencies
------------
* apache2 cookbook
* openssl cookbook

Usage
------------

To add a repo to a node (or several), just add the git_smart_http::default reciepe and the following vars to your node

```ruby
node[:git_smart_http][:domain]='gitserver.domain.tld'
# this creates/provides a bare repo under /var/git/myrepo1
node[:git_smart_http][:repos][:myrepo1][:username] = 'foo1'
node[:git_smart_http][:repos][:myrepo2][:username] = 'foo2'
node[:git_smart_http][:repos][:myrepo3][:username] = 'foo2'
## (this is optional, defautls are given/generated)
# this way you set the base dir
node[:gitsmarthttp][:gitroot]='/var/git/'
# this way you set the password, otherwise it is generated
node[:git_smart_http][:repos][:myrepo1][:password] = 'secret1'
node[:git_smart_http][:repos][:myrepo2][:password] = 'secret2'
node[:git_smart_http][:repos][:myrepo3][:password] = 'secret3'
```

Hooks
------------

If you want to deploy hooks, just write your own reciepe looking like this
```ruby
node[:git_smart_http][:repos][:themer] = {}
node[:git_smart_http][:repos][:themer][:username] = "themer"
node[:git_smart_http][:repos][:themer][:password] = secure_password

include_recipe "git_smart_http::default"
live_wc="/var/www/live"
stage_wc="/var/www/stage"
template "#{node[:git_smart_http][:repos][:themer][:path]}/hooks/post-receive" do
  source "themer_git_recieve_hook.erb"
  mode "0770"
  variables(
      :live_wc => live_wc,
      :stage_wc => stage_wc
  )
  owner 'www-data'
  group 'www-data'
end
```

This basically deploys the default receive hook for auto-deploying the git repo to live/stage
after the changes are pushed. Often called git deploy

Make it any better!!
------------

You have any suggestions / additions? Fork it and let me know, so i can merge