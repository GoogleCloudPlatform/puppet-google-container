# Copyright 2018 Google Inc.
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

# ----------------------------------------------------------------------------
#
#     ***     AUTO GENERATED CODE    ***    AUTO GENERATED CODE     ***
#
# ----------------------------------------------------------------------------
#
#     This file is automatically generated by Magic Modules and manual
#     changes will be clobbered when the file is regenerated.
#
#     Please read more about how to change this file in README.md and
#     CONTRIBUTING.md located at the root of this package.
#
# ----------------------------------------------------------------------------

require 'google/container/network/delete'
require 'google/container/network/get'
require 'google/container/network/post'
require 'google/container/network/put'
require 'google/container/property/boolean'
require 'google/container/property/cluster_name'
require 'google/container/property/integer'
require 'google/container/property/namevalues'
require 'google/container/property/nodepool_autoscaling'
require 'google/container/property/nodepool_config'
require 'google/container/property/nodepool_management'
require 'google/container/property/nodepool_upgrade_options'
require 'google/container/property/string'
require 'google/container/property/string_array'
require 'google/container/property/time'
require 'google/hash_utils'
require 'puppet'

Puppet::Type.type(:gcontainer_node_pool).provide(:google) do
  mk_resource_methods

  def self.instances
    debug('instances')
    raise [
      '"puppet resource" is not supported at the moment:',
      'TODO(nelsonjr): https://goto.google.com/graphite-bugs-view?id=167'
    ].join(' ')
  end

  def self.prefetch(resources)
    debug('prefetch')
    resources.each do |name, resource|
      project = resource[:project]
      debug("prefetch #{name}") if project.nil?
      debug("prefetch #{name} @ #{project}") unless project.nil?
      fetch = fetch_resource(resource, self_link(resource))
      resource.provider = present(name, fetch, resource) unless fetch.nil?
    end
  end

  def self.present(name, fetch, resource)
    result = new(
      { title: name, ensure: :present }.merge(fetch_to_hash(fetch, resource))
    )
    result
  end

  def self.fetch_to_hash(fetch, resource)
    {
      name: Google::Container::Property::String.api_munge(fetch['name']),
      config: Google::Container::Property::NodePoolConfig.api_munge(fetch['config']),
      version: Google::Container::Property::String.api_munge(fetch['version']),
      autoscaling: Google::Container::Property::NodePoolAutoscaling.api_munge(fetch['autoscaling']),
      management: Google::Container::Property::NodePoolManagement.api_munge(fetch['management']),
      initial_node_count: resource[:initial_node_count]
    }.reject { |_, v| v.nil? }
  end

  def exists?
    debug("exists? #{@property_hash[:ensure] == :present}")
    @property_hash[:ensure] == :present
  end

  def create
    debug('create')
    @created = true
    create_req = Google::Container::Network::Post.new(collection(@resource),
                                                      fetch_auth(@resource),
                                                      'application/json',
                                                      resource_to_request)
    wait_for_operation create_req.send, @resource
    @property_hash[:ensure] = :present
  end

  def destroy
    debug('destroy')
    @deleted = true
    delete_req = Google::Container::Network::Delete.new(self_link(@resource),
                                                        fetch_auth(@resource))
    wait_for_operation delete_req.send, @resource
    @property_hash[:ensure] = :absent
  end

  def flush
    debug('flush')
    # return on !@dirty is for aiding testing (puppet already guarantees that)
    return if @created || @deleted || !@dirty
    update_req = Google::Container::Network::Put.new(self_link(@resource),
                                                     fetch_auth(@resource),
                                                     'application/json',
                                                     resource_to_request)
    wait_for_operation update_req.send, @resource
  end

  def dirty(field, from, to)
    @dirty = {} if @dirty.nil?
    @dirty[field] = {
      from: from,
      to: to
    }
  end

  private

  def self.resource_to_hash(resource)
    {
      project: resource[:project],
      name: resource[:name],
      config: resource[:config],
      initial_node_count: resource[:initial_node_count],
      version: resource[:version],
      autoscaling: resource[:autoscaling],
      management: resource[:management],
      cluster: resource[:cluster],
      zone: resource[:zone]
    }.reject { |_, v| v.nil? }
  end

  def resource_to_request
    request = {
      name: @resource[:name],
      config: @resource[:config],
      initialNodeCount: @resource[:initial_node_count],
      autoscaling: @resource[:autoscaling],
      management: @resource[:management]
    }.reject { |_, v| v.nil? }
    # Format request to conform with API endpoint
    request = encode_request(request)
    debug "request: #{request}" unless ENV['PUPPET_HTTP_DEBUG'].nil?
    request.to_json
  end

  def fetch_auth(resource)
    self.class.fetch_auth(resource)
  end

  def self.fetch_auth(resource)
    Puppet::Type.type(:gauth_credential).fetch(resource)
  end

  def debug(message)
    puts("DEBUG: #{message}") if ENV['PUPPET_HTTP_VERBOSE']
    super(message)
  end

  def self.collection(data)
    URI.join(
      'https://container.googleapis.com/v1/',
      expand_variables(
        'projects/{{project}}/zones/{{zone}}/clusters/{{cluster}}/nodePools',
        data
      )
    )
  end

  def collection(data)
    self.class.collection(data)
  end

  def self.self_link(data)
    URI.join(
      'https://container.googleapis.com/v1/',
      expand_variables(
        'projects/{{project}}/zones/{{zone}}/clusters/{{cluster}}/nodePools/{{name}}',
        data
      )
    )
  end

  def self_link(data)
    self.class.self_link(data)
  end

  def self.return_if_object(response, allow_not_found = false)
    raise "Bad response: #{response.body}" \
      if response.is_a?(Net::HTTPBadRequest)
    raise "Bad response: #{response}" \
      unless response.is_a?(Net::HTTPResponse)
    return if response.is_a?(Net::HTTPNotFound) && allow_not_found 
    return if response.is_a?(Net::HTTPNoContent)
    result = JSON.parse(response.body)
    raise_if_errors result, %w[error errors], 'message'
    raise "Bad response: #{response}" unless response.is_a?(Net::HTTPOK)
    result
  end

  def return_if_object(response, allow_not_found = false)
    self.class.return_if_object(response, allow_not_found)
  end

  def self.extract_variables(template)
    template.scan(/{{[^}]*}}/).map { |v| v.gsub(/{{([^}]*)}}/, '\1') }
            .map(&:to_sym)
  end

  def self.expand_variables(template, var_data, extra_data = {})
    data = if var_data.class <= Hash
             var_data.merge(extra_data)
           else
             resource_to_hash(var_data).merge(extra_data)
           end
    extract_variables(template).each do |v|
      unless data.key?(v)
        raise "Missing variable :#{v} in #{data} on #{caller.join("\n")}}"
      end
      template.gsub!(/{{#{v}}}/, CGI.escape(data[v].to_s))
    end
    template
  end

  def expand_variables(template, var_data, extra_data = {})
    self.class.expand_variables(template, var_data, extra_data)
  end

  def fetch_resource(resource, self_link)
    self.class.fetch_resource(resource, self_link)
  end

  def async_op_url(data, extra_data = {})
    URI.join(
      'https://container.googleapis.com/v1/',
      expand_variables(
        'projects/{{project}}/zones/{{zone}}/operations/{{op_id}}',
        data, extra_data
      )
    )
  end

  def wait_for_operation(response, resource)
    op_result = return_if_object(response)
    return if op_result.nil?
    status = ::Google::HashUtils.navigate(op_result, %w[status])
    fetch_resource(
      resource,
      URI.parse(::Google::HashUtils.navigate(wait_for_completion(status,
                                                                 op_result,
                                                                 resource),
                                             %w[targetLink]))
    )
  end

  def wait_for_completion(status, op_result, resource)
    op_id = ::Google::HashUtils.navigate(op_result, %w[name])
    op_uri = async_op_url(resource, op_id: op_id)
    while status != 'DONE'
      debug("Waiting for completion of operation #{op_id}")
      raise_if_errors op_result, %w[error errors], 'message'
      sleep 1.0
      raise "Invalid result '#{status}' on gcontainer_node_pool." \
        unless %w[PENDING RUNNING DONE ABORTING].include?(status)
      op_result = fetch_resource(resource, op_uri)
      status = ::Google::HashUtils.navigate(op_result, %w[status])
    end
    op_result
  end

  def raise_if_errors(response, err_path, msg_field)
    self.class.raise_if_errors(response, err_path, msg_field)
  end

  # Google Container Engine API has its own layout for the create method,
  # defined like this:
  #
  # {
  #   'nodePool': {
  #     ... node pool data
  #   }
  # }
  #
  # Format the request to match the expected input by the API
  def self.encode_request(resource_request)
    {
      'nodePool' => resource_request
    }
  end

  def encode_request(resource_request)
    self.class.encode_request(resource_request)
  end

  def self.fetch_resource(resource, self_link)
    get_request = ::Google::Container::Network::Get.new(
      self_link, fetch_auth(resource)
    )
    return_if_object get_request.send, true
  end

  def self.raise_if_errors(response, err_path, msg_field)
    errors = ::Google::HashUtils.navigate(response, err_path)
    raise_error(errors, msg_field) unless errors.nil?
  end

  def self.raise_error(errors, msg_field)
    raise IOError, ['Operation failed:',
                    errors.map { |e| e[msg_field] }.join(', ')].join(' ')
  end
end
