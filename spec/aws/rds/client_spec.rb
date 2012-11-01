# Copyright 2011-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require 'spec_helper'

module AWS
  class RDS
    describe Client do

      let(:credentials) {{
        :access_key_id => 'akid',
        :secret_access_key => 'secret'
      }}

      let(:handler) { double('handler', :handle => nil) }

      let(:config) {
        AWS.config.with(credentials.merge(:http_handler => handler))
      }

      let(:client) { config.rds_client }

      let(:now) { Time.now }

      let(:namespace) {
        'http://rds.amazonaws.com/doc/2012-07-31/'
      }

      context '#create_db_snapshot' do

        it 'correctly removes both wrapping xml elements' do

          xml = <<-XML.strip
<CreateDBSnapshotResponse xmlns="#{namespace}">
  <CreateDBSnapshotResult>
    <DBSnapshot>
      <Port>3306</Port>
      <Engine>mysql</Engine>
      <Status>creating</Status>
      <SnapshotType>manual</SnapshotType>
      <LicenseModel>general-public-license</LicenseModel>
      <DBInstanceIdentifier>abc</DBInstanceIdentifier>
      <EngineVersion>5.5.27</EngineVersion>
      <DBSnapshotIdentifier>name5</DBSnapshotIdentifier>
      <AvailabilityZone>us-east-1a</AvailabilityZone>
      <InstanceCreateTime>#{now.iso8601}</InstanceCreateTime>
      <AllocatedStorage>1024</AllocatedStorage>
      <MasterUsername>root</MasterUsername>
    </DBSnapshot>
  </CreateDBSnapshotResult>
  <ResponseMetadata>
    <RequestId>984e0bd4-23f4-11e2-b390-91eea8f6e859</RequestId>
  </ResponseMetadata>
</CreateDBSnapshotResponse>
          XML

          handler.should_receive(:handle) do |req,resp|
            resp.status = 200
            resp.body = xml
          end

          options = {}
          options[:db_instance_identifier] = 'abc'
          options[:db_snapshot_identifier] = 'abc'
          resp = client.create_db_snapshot(options)
          resp.data.should eq({:port=>3306, :engine=>"mysql", :status=>"creating", :snapshot_type=>"manual", :license_model=>"general-public-license", :db_instance_identifier=>"abc", :engine_version=>"5.5.27", :db_snapshot_identifier=>"name5", :availability_zone=>"us-east-1a", :instance_create_time=>Time.parse(now.iso8601), :allocated_storage=>1024, :master_username=>"root", :response_metadata=>{:request_id=>"984e0bd4-23f4-11e2-b390-91eea8f6e859"}})
        end

      end

    end
  end
end