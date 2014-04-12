# libraries/influxdb.rb
#
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2014 Simple Finance Technology Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Helper methods for managing InfluxDB

require 'chef/resource/package'
require 'chef/resource/chef_gem'

module InfluxDB
  module Helpers

    INFLUXDB_CONFIG = '/opt/influxdb/shared/config.toml'

    # TODO : Configurable administrator creds
    def self.client(user = 'root', pass = 'root')
      require 'influxdb'
      return InfluxDB::Client.new(username: user, password: pass)
    end

    def self.render_config(hash, run_context)
      self.install_toml(run_context)
      self.require_toml
      self.config_file(hash, run_context)
    end

    def self.install_toml(run_context)
      toml_gem = Chef::Resource::ChefGem.new('toml', run_context)
      toml_gem.run_action :install
    end

    def self.require_toml
      require 'toml'
    end

    def self.config_file(hash, run_context)
      f = Chef::Resource::File.new(INFLUXDB_CONFIG, run_context)
      f.owner 'root'
      f.mode 00644
      f.content TOML::Generator.new(hash).body
      f.run_action :create
    end
  end
end
