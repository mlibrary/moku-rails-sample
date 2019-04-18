# Moku Rails Sample

This is a minimal example Rails application that is ready to be deployed with
[Moku](https://github.com/mlibrary/moku). It was generated with `rails new`
and the `--skip-spring` option.

## Versions

 * Ruby 2.6.3
 * Rails 5.2.3
 * Bundler 2.0.1

## Modifications for Moku support

There are only a few changes needed to support deployment with Moku. The most
important one is that infrastructure settings like hosts, paths, and
credentials are read from the infrastructure.yml file placed during deployment.
This application is an example of generic modifications that can be applied by
hand to simplify that process and keep all of the Moku details out of the
application.

This is done by depending on [Ettin](https://github.com/mlibrary/ettin) (or,
alternatively, the `config` gem). The app uses values from the global Settings
object, with each of the keys defined in `config/settings.yml`. There are some
environment-specific defaults in `config/settings/*.yml`. Actual values and
overrides can be supplied in `settings.local.yml` or
`settings/<environment>.local.yml`. For deployment, these files would reside
in the developer configuration branch for the instance.

The general recommendation is to use a generic `settings.local.yml` that maps
values from Moku to the keys for the application, and supply other values in,
for example, `production.local.yml`.

This net approach allows applications to be cloned and run with defaults for
development purposes, and then deployed with minimal overrides to map in
infrastructure and instance-specific, developer-supplied configuration.

### Specifying Ruby version

Application deployed with Moku need a `.ruby-version` file. This file should
contain only the minor version so the deployed application will continue to
use the most recent "teeny" version without changes. This example application
specifies `2.6`. If you are working locally with rbenv, you may need to set up
[rbenv-aliases](https://github.com/tpope/rbenv-aliases). If you use chruby with
automatic switching, this support is built in.

### Reading From Infrastructure Configuration

For typical basic applications, there are only two backing services: a database
and Redis to support ActionCable. Here is an example to read from
`infrastructure.yml` for those settings. This would be added to the developer
configuration as `config/settings.local.yml`:

```
<%
begin
# Get a reference to the infrastructure.yml file installed by moku.
  @moku = YAML.load_file('infrastructure.yml')
rescue
  raise "Can't load infrastructure.yml"
end
%>

rails:
  database:
    url: <%= @moku['db']['url'] %>
  cable:
    adapter: redis
    url: <%= @moku['redis']['url'] %>
    channel_prefix: <%= @moku['instance_name'] %>
```

## Application Template

There is a Rails [application template](https://guides.rubyonrails.org/rails_application_templates.html)
in `template.rb` that can be used to create a new application or be applied to
an existing one. It was used to modify the base application here with this command:

```
$ bin/rails app:template LOCATION=./template.rb
```

An existing application can be modified like so:

```
$ bin/rails app:template LOCATION=https://raw.githubusercontent.com/mlibrary/moku-rails-sample/master/template.rb
```

Or a new application can be generated like so:

```
$ rails new my-new-app -m https://raw.githubusercontent.com/mlibrary/moku-rails-sample/template.rb
```

Note that the template does not create or modify a `.ruby-version` file.

## License

This sample is licensed under the New BSD License (BSD-3-Clause).

```
Copyright 2019 Regents of the University of Michigan

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
