#
# Author:: Adam Jacob (<adam@chef.io>)
# Author:: Daniel DeLeo (<dan@chef.io>)
# Copyright:: Copyright 2008-2016, Chef Software Inc.
#
# License:: Apache License, Version 2.0
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

require "spec_helper"
require "chef/provider/user/useradd"

describe Chef::Provider::User::Useradd do

  subject(:provider) do
    p = described_class.new(@new_resource, @run_context)
    p.current_resource = @current_resource
    p
  end

  supported_useradd_options = {
    "comment" => "-c",
    "gid" => "-g",
    "uid" => "-u",
    "shell" => "-s",
    "password" => "-p",
  }

  include_examples "a useradd-based user provider", supported_useradd_options

  describe "manage_user" do
    # CHEF-5247: Chef::Provider::User::Solaris subclasses Chef::Provider::User::Useradd, but does not use usermod to change passwords.
    # Thus, a call to Solaris#manage_user calls Solaris#manage_password and Useradd#manage_user, but the latter should be a no-op.
    it "should not run the command if universal_options is an empty array" do
      allow(provider).to receive(:universal_options).and_return([])
      expect(provider).not_to receive(:shell_out!)
      provider.manage_user
    end
  end

  describe "manage_home behavior" do
    before(:each) do
      @new_resource = Chef::Resource::User.new("adam", @run_context)
      @current_resource = Chef::Resource::User.new("adam", @run_context)
    end

    it "by default manage_home is nil and supports[:manage_home] is nil and we do not -M" do
      expect( @new_resource.manage_home ).to be nil
      expect( @new_resource.supports[:manage_home] ).to be nil
      expect( provider.supports_manage_home? ).to be true
      expect( provider.managing_home_dir? ).to be true
      expect( provider.useradd_options ).to eql([])
    end

    it "setting manage home to true is the same as the default beahvior" do
      @new_resource.manage_home true
      expect( @new_resource.manage_home ).to be true
      expect( @new_resource.supports[:manage_home] ).to be nil
      expect( provider.supports_manage_home? ).to be true
      expect( provider.managing_home_dir? ).to be true
      expect( provider.useradd_options ).to eql([])
    end

    it "setting manage home to false adds -M" do
      @new_resource.manage_home false
      expect( @new_resource.manage_home ).to be false
      expect( @new_resource.supports[:manage_home] ).to be nil
      expect( provider.supports_manage_home? ).to be true
      expect( provider.managing_home_dir? ).to be false
      expect( provider.useradd_options ).to eql(["-M"])
    end

    it "supports[:manage_home] behaves the same as default when manage_home is nil" do
      expect( @new_resource.manage_home ).to be nil
      @new_resource.supports[:manage_home] = true
      expect( @new_resource.supports[:manage_home] ).to be true
      expect( provider.supports_manage_home? ).to be true
      expect( provider.managing_home_dir? ).to be true
      expect( provider.useradd_options ).to eql([])
    end

    it "supports[:manage_home] behaves the same as default when manage_home is true" do
      @new_resource.manage_home true
      @new_resource.supports[:manage_home] = true
      expect( @new_resource.manage_home ).to be true
      expect( @new_resource.supports[:manage_home] ).to be true
      expect( provider.supports_manage_home? ).to be true
      expect( provider.managing_home_dir? ).to be true
      expect( provider.useradd_options ).to eql([])
    end

    it "supports[:manage_home] behaves the same as default when manage_home is false" do
      @new_resource.manage_home false
      @new_resource.supports[:manage_home] = true
      expect( @new_resource.manage_home ).to be false
      expect( @new_resource.supports[:manage_home] ).to be true
      expect( provider.supports_manage_home? ).to be true
      expect( provider.managing_home_dir? ).to be false
      expect( provider.useradd_options ).to eql(["-M"])
    end

    it "supports[:manage_home] to false does not manage home when manage_home is nil" do
      expect( @new_resource.manage_home ).to be nil
      @new_resource.supports[:manage_home] = false
      expect( @new_resource.supports[:manage_home] ).to be false
      expect( provider.supports_manage_home? ).to be false
      expect( provider.managing_home_dir? ).to be false
      expect( provider.useradd_options ).to eql(["-M"])
    end

    it "supports[:manage_home] to false does not manage home when manage_home is true" do
      @new_resource.manage_home true
      @new_resource.supports[:manage_home] = false
      expect( @new_resource.manage_home ).to be true
      expect( @new_resource.supports[:manage_home] ).to be false
      expect( provider.supports_manage_home? ).to be false
      expect( provider.managing_home_dir? ).to be false
      expect( provider.useradd_options ).to eql(["-M"])
    end

    it "supports[:manage_home] to false does not manage home when manage_home is false" do
      @new_resource.manage_home false
      @new_resource.supports[:manage_home] = false
      expect( @new_resource.manage_home ).to be false
      expect( @new_resource.supports[:manage_home] ).to be false
      expect( provider.supports_manage_home? ).to be false
      expect( provider.managing_home_dir? ).to be false
      expect( provider.useradd_options ).to eql(["-M"])
    end
  end
end
