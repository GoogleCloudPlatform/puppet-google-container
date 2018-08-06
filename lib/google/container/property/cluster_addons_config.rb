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

require 'google/container/property/base'

module Google
  module Container
    module Data
      # A class to manage data for AddonsConfig for cluster.
      class ClusterAddonsConfig
        include Comparable

        attr_reader :http_load_balancing
        attr_reader :horizontal_pod_autoscaling

        def to_json(_arg = nil)
          {
            'httpLoadBalancing' => http_load_balancing,
            'horizontalPodAutoscaling' => horizontal_pod_autoscaling
          }.reject { |_k, v| v.nil? }.to_json
        end

        def to_s
          {
            http_load_balancing: http_load_balancing,
            horizontal_pod_autoscaling: horizontal_pod_autoscaling
          }.reject { |_k, v| v.nil? }.map { |k, v| "#{k}: #{v}" }.join(', ')
        end

        def ==(other)
          return false unless other.is_a? ClusterAddonsConfig
          compare_fields(other).each do |compare|
            next if compare[:self].nil? || compare[:other].nil?
            return false if compare[:self] != compare[:other]
          end
          true
        end

        def <=>(other)
          return false unless other.is_a? ClusterAddonsConfig
          compare_fields(other).each do |compare|
            next if compare[:self].nil? || compare[:other].nil?
            result = compare[:self] <=> compare[:other]
            return result unless result.zero?
          end
          0
        end

        private

        def compare_fields(other)
          [
            { self: http_load_balancing, other: other.http_load_balancing },
            { self: horizontal_pod_autoscaling, other: other.horizontal_pod_autoscaling }
          ]
        end
      end

      # Manages a ClusterAddonsConfig nested object
      # Data is coming from the GCP API
      class ClusterAddonsConfigApi < ClusterAddonsConfig
        def initialize(args)
          @http_load_balancing = Google::Container::Property::ClusterHttpLoadBalancing.api_munge(
            args['httpLoadBalancing']
          )
          @horizontal_pod_autoscaling =
            Google::Container::Property::ClusterHorizontalPodAutoscaling.api_munge(
              args['horizontalPodAutoscaling']
            )
        end
      end

      # Manages a ClusterAddonsConfig nested object
      # Data is coming from the Puppet manifest
      class ClusterAddonsConfigCatalog < ClusterAddonsConfig
        def initialize(args)
          @http_load_balancing = Google::Container::Property::ClusterHttpLoadBalancing.unsafe_munge(
            args['http_load_balancing']
          )
          @horizontal_pod_autoscaling =
            Google::Container::Property::ClusterHorizontalPodAutoscaling.unsafe_munge(
              args['horizontal_pod_autoscaling']
            )
        end
      end
    end

    module Property
      # A class to manage input to AddonsConfig for cluster.
      class ClusterAddonsConfig < Google::Container::Property::Base
        # Used for parsing Puppet catalog
        def unsafe_munge(value)
          self.class.unsafe_munge(value)
        end

        # Used for parsing Puppet catalog
        def self.unsafe_munge(value)
          return if value.nil?
          Data::ClusterAddonsConfigCatalog.new(value)
        end

        # Used for parsing GCP API responses
        def self.api_munge(value)
          return if value.nil?
          Data::ClusterAddonsConfigApi.new(value)
        end
      end
    end
  end
end
