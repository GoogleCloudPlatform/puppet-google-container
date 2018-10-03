# Google Container Engine Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/google/gcontainer.svg)](https://forge.puppetlabs.com/google/gcontainer)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](
    #module-description)
2. [Setup - The basics of getting started with Google Container Engine](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](
   #reference)
    - [Classes](#classes)
    - [Bolt Tasks](#bolt-tasks)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

This Puppet module manages the resource of Google Container Engine.
You can manage its resources using standard Puppet DSL and the module will,
under the hood, ensure the state described will be reflected in the Google
Cloud Platform resources.

## Setup

To install this module on your Puppet Master (or Puppet Client/Agent), use the
Puppet module installer:

    puppet module install google-gcontainer

Optionally you can install support to _all_ Google Cloud Platform products at
once by installing our "bundle" [`google-cloud`][bundle-forge] module:

    puppet module install google-cloud

Since this module depends on the `googleauth` and `google-api-client` gems,
you will also need to install those, with

    /opt/puppetlabs/puppet/bin/gem install googleauth google-api-client

If you prefer, you could also add the following to your puppet manifest:

		package { [
				'googleauth',
				'google-api-client',
			]:
				ensure   => present,
				provider => puppet_gem,
		}

## Usage

### Credentials

All Google Cloud Platform modules use an unified authentication mechanism,
provided by the [`google-gauth`][] module. Don't worry, it is automatically
installed when you install this module.

```puppet
gauth_credential { 'mycred':
  path     => $cred_path, # e.g. '/home/nelsonjr/my_account.json'
  provider => serviceaccount,
  scopes   => [
    'https://www.googleapis.com/auth/cloud-platform',
  ],
}
```

Please refer to the [`google-gauth`][] module for further requirements, i.e.
required gems.

### Examples

#### `gcontainer_cluster`

```puppet
gcontainer_cluster { "mycluster-${cluster_id}":
  ensure             => present,
  initial_node_count => 2,
  master_auth        => {
    username => 'cluster_admin',
    password => 'my-secret-password',
  },
  node_config        => {
    machine_type => 'n1-standard-4', # we want a 4-core machine for our cluster
    disk_size_gb => 500,             # ... and a lot of disk space
  },
  zone               => 'us-central1-a',
  project            => $project, # e.g. 'my-test-project'
  credential         => 'mycred',
}

```

#### `gcontainer_node_pool`

```puppet
# A node pool requires a container to exist. Please ensure its presence with:
# gcontainer_cluster { ..... }
gcontainer_node_pool { 'web-servers':
  ensure             => present,
  initial_node_count => 4,
  cluster            => "mycluster-${cluster_id}",
  zone               => 'us-central1-a',
  project            => $project, # e.g. 'my-test-project'
  credential         => 'mycred',
}

```

#### `gcontainer_kube_config`

```puppet
# ~/.kube/config is used by Kubernetes client (kubectl)
gcontainer_kube_config { '/home/nelsona/.kube/config':
  ensure     => present,
  context    => "gke-mycluster-${cluster_id}",
  cluster    => "mycluster-${cluster_id}",
  zone       => 'us-central1-a',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

# A file named ~/.puppetlabs/etc/puppet/kubernetes is used by the
# garethr-kubernetes module.
gcontainer_kube_config { '/home/nelsona/.puppetlabs/etc/puppet/kubernetes.conf':
  ensure     => present,
  cluster    => "mycluster-${cluster_id}",
  zone       => 'us-central1-a',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```


### Classes

#### Public classes

* [`gcontainer_cluster`][]:
    A Google Container Engine cluster.
* [`gcontainer_node_pool`][]:
    NodePool contains the name and configuration for a cluster's node pool.
    Node pools are a set of nodes (i.e. VM's), with a common configuration and
    specification, under the control of the cluster master. They may have a
    set of Kubernetes labels applied to them, which may be used to reference
    them during pod scheduling. They may also be resized up or down, to
    accommodate the workload.
* [`gcontainer_kube_config`][]:
    Generates a compatible Kuberenetes '.kube/config' file

### About output only properties

Some fields are output-only. It means you cannot set them because they are
provided by the Google Cloud Platform. Yet they are still useful to ensure the
value the API is assigning (or has assigned in the past) is still the value you
expect.

For example in a DNS the name servers are assigned by the Google Cloud DNS
service. Checking these values once created is useful to make sure your upstream
and/or root DNS masters are in sync.  Or if you decide to use the object ID,
e.g. the VM unique ID, for billing purposes. If the VM gets deleted and
recreated it will have a different ID, despite the name being the same. If that
detail is important to you you can verify that the ID of the object did not
change by asserting it in the manifest.

### Parameters

#### `gcontainer_cluster`

A Google Container Engine cluster.

#### Example

```puppet
gcontainer_cluster { "mycluster-${cluster_id}":
  ensure             => present,
  initial_node_count => 2,
  master_auth        => {
    username => 'cluster_admin',
    password => 'my-secret-password',
  },
  node_config        => {
    machine_type => 'n1-standard-4', # we want a 4-core machine for our cluster
    disk_size_gb => 500,             # ... and a lot of disk space
  },
  zone               => 'us-central1-a',
  project            => $project, # e.g. 'my-test-project'
  credential         => 'mycred',
}

```

#### Reference

```puppet
gcontainer_cluster { 'id-of-resource':
  addons_config           => {
    horizontal_pod_autoscaling => {
      disabled => boolean,
    },
    http_load_balancing        => {
      disabled => boolean,
    },
  },
  cluster_ipv4_cidr       => string,
  create_time             => time,
  current_master_version  => string,
  current_node_count      => integer,
  current_node_version    => string,
  description             => string,
  endpoint                => string,
  expire_time             => time,
  initial_cluster_version => string,
  initial_node_count      => integer,
  location                => [
    string,
    ...
  ],
  logging_service         => 'logging.googleapis.com' or 'none',
  master_auth             => {
    client_certificate     => string,
    client_key             => string,
    cluster_ca_certificate => string,
    password               => string,
    username               => string,
  },
  monitoring_service      => 'monitoring.googleapis.com' or 'none',
  name                    => string,
  network                 => string,
  node_config             => {
    disk_size_gb    => integer,
    image_type      => string,
    labels          => namevalues,
    local_ssd_count => integer,
    machine_type    => string,
    metadata        => namevalues,
    oauth_scopes    => [
      string,
      ...
    ],
    preemptible     => boolean,
    service_account => string,
    tags            => [
      string,
      ...
    ],
  },
  node_ipv4_cidr_size     => integer,
  services_ipv4_cidr      => string,
  subnetwork              => string,
  zone                    => string,
  project                 => string,
  credential              => reference to gauth_credential,
}
```

##### `name`

  The name of this cluster. The name must be unique within this project
  and zone, and can be up to 40 characters. Must be Lowercase letters,
  numbers, and hyphens only. Must start with a letter. Must end with a
  number or a letter.

##### `description`

  An optional description of this cluster.

##### `initial_node_count`

Required.  The number of nodes to create in this cluster. You must ensure that
  your Compute Engine resource quota is sufficient for this number of
  instances. You must also have available firewall and routes quota. For
  requests, this field should only be used in lieu of a "nodePool"
  object, since this configuration (along with the "nodeConfig") will be
  used to create a "NodePool" object with an auto-generated name. Do not
  use this and a nodePool at the same time.

##### `node_config`

  Parameters used in creating the cluster's nodes.
  For requests, this field should only be used in lieu of a "nodePool"
  object, since this configuration (along with the "initialNodeCount")
  will be used to create a "NodePool" object with an auto-generated
  name. Do not use this and a nodePool at the same time. For responses,
  this field will be populated with the node configuration of the first
  node pool. If unspecified, the defaults are used.

##### node_config/machine_type
  The name of a Google Compute Engine machine type (e.g.
  n1-standard-1).  If unspecified, the default machine type is
  n1-standard-1.

##### node_config/disk_size_gb
  Size of the disk attached to each node, specified in GB. The
  smallest allowed disk size is 10GB. If unspecified, the default
  disk size is 100GB.

##### node_config/oauth_scopes
  The set of Google API scopes to be made available on all of the
  node VMs under the "default" service account.
  The following scopes are recommended, but not required, and by
  default are not included:
  https://www.googleapis.com/auth/compute is required for mounting
  persistent storage on your nodes.
  https://www.googleapis.com/auth/devstorage.read_only is required
  for communicating with gcr.io (the Google Container Registry).
  If unspecified, no scopes are added, unless Cloud Logging or Cloud
  Monitoring are enabled, in which case their required scopes will
  be added.

##### node_config/service_account
  The Google Cloud Platform Service Account to be used by the node
  VMs.  If no Service Account is specified, the "default" service
  account is used.

##### node_config/metadata
  The metadata key/value pairs assigned to instances in the cluster.
  Keys must conform to the regexp [a-zA-Z0-9-_]+ and be less than
  128 bytes in length. These are reflected as part of a URL in the
  metadata server. Additionally, to avoid ambiguity, keys must not
  conflict with any other metadata keys for the project or be one of
  the four reserved keys: "instance-template", "kube-env",
  "startup-script", and "user-data"
  Values are free-form strings, and only have meaning as interpreted
  by the image running in the instance. The only restriction placed
  on them is that each value's size must be less than or equal to 32
  KB.
  The total size of all keys and values must be less than 512 KB.
  An object containing a list of "key": value pairs.
  Example: { "name": "wrench", "mass": "1.3kg", "count": "3" }.

##### node_config/image_type
  The image type to use for this node.  Note that for a given image
  type, the latest version of it will be used.

##### node_config/labels
  The map of Kubernetes labels (key/value pairs) to be applied to
  each node. These will added in addition to any default label(s)
  that Kubernetes may apply to the node. In case of conflict in
  label keys, the applied set may differ depending on the Kubernetes
  version -- it's best to assume the behavior is undefined and
  conflicts should be avoided. For more information, including usage
  and the valid values, see:
  http://kubernetes.io/v1.1/docs/user-guide/labels.html
  An object containing a list of "key": value pairs.
  Example: { "name": "wrench", "mass": "1.3kg", "count": "3" }.

##### node_config/local_ssd_count
  The number of local SSD disks to be attached to the node.
  The limit for this value is dependant upon the maximum number of
  disks available on a machine per zone. See:
  https://cloud.google.com/compute/docs/disks/local-ssd#local_ssd_limits
  for more information.

##### node_config/tags
  The list of instance tags applied to all nodes. Tags are used to
  identify valid sources or targets for network firewalls and are
  specified by the client during cluster or node pool creation. Each
  tag within the list must comply with RFC1035.

##### node_config/preemptible
  Whether the nodes are created as preemptible VM instances. See:
  https://cloud.google.com/compute/docs/instances/preemptible for
  more inforamtion about preemptible VM instances.

##### `master_auth`

  The authentication information for accessing the master endpoint.

##### master_auth/username
  The username to use for HTTP basic authentication to the master
  endpoint.

##### master_auth/password
  The password to use for HTTP basic authentication to the master
  endpoint. Because the master endpoint is open to the Internet, you
  should create a strong password.

##### master_auth/cluster_ca_certificate
Output only.  Base64-encoded public certificate that is the root of trust for
  the cluster.

##### master_auth/client_certificate
Output only.  Base64-encoded public certificate used by clients to authenticate
  to the cluster endpoint.

##### master_auth/client_key
Output only.  Base64-encoded private key used by clients to authenticate to the
  cluster endpoint.

##### `logging_service`

  The logging service the cluster should use to write logs. Currently
  available options:
  logging.googleapis.com - the Google Cloud Logging service.
  none - no logs will be exported from the cluster.
  if left as an empty string,logging.googleapis.com will be used.

##### `monitoring_service`

  The monitoring service the cluster should use to write metrics.
  Currently available options:
  monitoring.googleapis.com - the Google Cloud Monitoring service.
  none - no metrics will be exported from the cluster.
  if left as an empty string, monitoring.googleapis.com will be used.

##### `network`

  The name of the Google Compute Engine network to which the cluster is
  connected. If left unspecified, the default network will be used.
  To ensure it exists and it is operations, configure the network
  using 'gcompute_network' resource.

##### `cluster_ipv4_cidr`

  The IP address range of the container pods in this cluster, in CIDR
  notation (e.g. 10.96.0.0/14). Leave blank to have one automatically
  chosen or specify a /14 block in 10.0.0.0/8.

##### `addons_config`

  Configurations for the various addons available to run in the cluster.

##### addons_config/http_load_balancing
  Configuration for the HTTP (L7) load balancing controller addon,
  which makes it easy to set up HTTP load balancers for services in
  a cluster.

##### addons_config/http_load_balancing/disabled
  Whether the HTTP Load Balancing controller is enabled in the
  cluster. When enabled, it runs a small pod in the cluster that
  manages the load balancers.

##### addons_config/horizontal_pod_autoscaling
  Configuration for the horizontal pod autoscaling feature, which
  increases or decreases the number of replica pods a replication
  controller has based on the resource usage of the existing pods.

##### addons_config/horizontal_pod_autoscaling/disabled
  Whether the Horizontal Pod Autoscaling feature is enabled in
  the cluster. When enabled, it ensures that a Heapster pod is
  running in the cluster, which is also used by the Cloud
  Monitoring service.

##### `subnetwork`

  The name of the Google Compute Engine subnetwork to which the cluster
  is connected.

##### `location`

  The list of Google Compute Engine locations in which the cluster's
  nodes should be located.

##### `zone`

Required.  The zone where the cluster is deployed


##### Output-only properties

* `endpoint`: Output only.
  The IP address of this cluster's master endpoint.
  The endpoint can be accessed from the internet at
  https://username:password@endpoint/
  See the masterAuth property of this resource for username and password
  information.

* `initial_cluster_version`: Output only.
  The software version of the master endpoint and kubelets used in the
  cluster when it was first created. The version can be upgraded over
  time.

* `current_master_version`: Output only.
  The current software version of the master endpoint.

* `current_node_version`: Output only.
  The current version of the node software components. If they are
  currently at multiple versions because they're in the process of being
  upgraded, this reflects the minimum version of all nodes.

* `create_time`: Output only.
  The time the cluster was created, in RFC3339 text format.

* `node_ipv4_cidr_size`: Output only.
  The size of the address space on each node for hosting containers.
  This is provisioned from within the container_ipv4_cidr range.

* `services_ipv4_cidr`: Output only.
  The IP address range of the Kubernetes services in this cluster, in
  CIDR notation (e.g. 1.2.3.4/29). Service addresses are typically put
  in the last /16 from the container CIDR.

* `current_node_count`: Output only.
  The number of nodes currently in the cluster.

* `expire_time`: Output only.
  The time the cluster will be automatically deleted in RFC3339 text
  format.

#### `gcontainer_node_pool`

NodePool contains the name and configuration for a cluster's node pool.
Node pools are a set of nodes (i.e. VM's), with a common configuration and
specification, under the control of the cluster master. They may have a
set of Kubernetes labels applied to them, which may be used to reference
them during pod scheduling. They may also be resized up or down, to
accommodate the workload.


#### Example

```puppet
# A node pool requires a container to exist. Please ensure its presence with:
# gcontainer_cluster { ..... }
gcontainer_node_pool { 'web-servers':
  ensure             => present,
  initial_node_count => 4,
  cluster            => "mycluster-${cluster_id}",
  zone               => 'us-central1-a',
  project            => $project, # e.g. 'my-test-project'
  credential         => 'mycred',
}

```

#### Reference

```puppet
gcontainer_node_pool { 'id-of-resource':
  autoscaling        => {
    enabled        => boolean,
    max_node_count => integer,
    min_node_count => integer,
  },
  cluster            => reference to gcontainer_cluster,
  config             => {
    disk_size_gb    => integer,
    image_type      => string,
    labels          => namevalues,
    local_ssd_count => integer,
    machine_type    => string,
    metadata        => namevalues,
    oauth_scopes    => [
      string,
      ...
    ],
    preemptible     => boolean,
    service_account => string,
    tags            => [
      string,
      ...
    ],
  },
  initial_node_count => integer,
  management         => {
    auto_repair     => boolean,
    auto_upgrade    => boolean,
    upgrade_options => {
      auto_upgrade_start_time => time,
      description             => string,
    },
  },
  name               => string,
  version            => string,
  zone               => string,
  project            => string,
  credential         => reference to gauth_credential,
}
```

##### `name`

  The name of the node pool.

##### `config`

  The node configuration of the pool.

##### config/machine_type
  The name of a Google Compute Engine machine type (e.g.
  n1-standard-1).  If unspecified, the default machine type is
  n1-standard-1.

##### config/disk_size_gb
  Size of the disk attached to each node, specified in GB. The
  smallest allowed disk size is 10GB. If unspecified, the default
  disk size is 100GB.

##### config/oauth_scopes
  The set of Google API scopes to be made available on all of the
  node VMs under the "default" service account.
  The following scopes are recommended, but not required, and by
  default are not included:
  https://www.googleapis.com/auth/compute is required for mounting
  persistent storage on your nodes.
  https://www.googleapis.com/auth/devstorage.read_only is required
  for communicating with gcr.io (the Google Container Registry).
  If unspecified, no scopes are added, unless Cloud Logging or Cloud
  Monitoring are enabled, in which case their required scopes will
  be added.

##### config/service_account
  The Google Cloud Platform Service Account to be used by the node
  VMs.  If no Service Account is specified, the "default" service
  account is used.

##### config/metadata
  The metadata key/value pairs assigned to instances in the cluster.
  Keys must conform to the regexp [a-zA-Z0-9-_]+ and be less than
  128 bytes in length. These are reflected as part of a URL in the
  metadata server. Additionally, to avoid ambiguity, keys must not
  conflict with any other metadata keys for the project or be one of
  the four reserved keys: "instance-template", "kube-env",
  "startup-script", and "user-data"
  Values are free-form strings, and only have meaning as interpreted
  by the image running in the instance. The only restriction placed
  on them is that each value's size must be less than or equal to 32
  KB.
  The total size of all keys and values must be less than 512 KB.
  An object containing a list of "key": value pairs.
  Example: { "name": "wrench", "mass": "1.3kg", "count": "3" }.

##### config/image_type
  The image type to use for this node.  Note that for a given image
  type, the latest version of it will be used.

##### config/labels
  The map of Kubernetes labels (key/value pairs) to be applied to
  each node. These will added in addition to any default label(s)
  that Kubernetes may apply to the node. In case of conflict in
  label keys, the applied set may differ depending on the Kubernetes
  version -- it's best to assume the behavior is undefined and
  conflicts should be avoided. For more information, including usage
  and the valid values, see:
  http://kubernetes.io/v1.1/docs/user-guide/labels.html
  An object containing a list of "key": value pairs.
  Example: { "name": "wrench", "mass": "1.3kg", "count": "3" }.

##### config/local_ssd_count
  The number of local SSD disks to be attached to the node.
  The limit for this value is dependant upon the maximum number of
  disks available on a machine per zone. See:
  https://cloud.google.com/compute/docs/disks/local-ssd#local_ssd_limits
  for more information.

##### config/tags
  The list of instance tags applied to all nodes. Tags are used to
  identify valid sources or targets for network firewalls and are
  specified by the client during cluster or node pool creation. Each
  tag within the list must comply with RFC1035.

##### config/preemptible
  Whether the nodes are created as preemptible VM instances. See:
  https://cloud.google.com/compute/docs/instances/preemptible for
  more inforamtion about preemptible VM instances.

##### `initial_node_count`

Required.  The initial node count for the pool. You must ensure that your Compute
  Engine resource quota is sufficient for this number of instances. You
  must also have available firewall and routes quota.

##### `autoscaling`

  Autoscaler configuration for this NodePool. Autoscaler is enabled only
  if a valid configuration is present.

##### autoscaling/enabled
  Is autoscaling enabled for this node pool.

##### autoscaling/min_node_count
  Minimum number of nodes in the NodePool. Must be >= 1 and <=
  maxNodeCount.

##### autoscaling/max_node_count
  Maximum number of nodes in the NodePool. Must be >= minNodeCount.
  There has to enough quota to scale up the cluster.

##### `management`

  Management configuration for this NodePool.

##### management/auto_upgrade
  A flag that specifies whether node auto-upgrade is enabled for the
  node pool. If enabled, node auto-upgrade helps keep the nodes in
  your node pool up to date with the latest release version of
  Kubernetes.

##### management/auto_repair
  A flag that specifies whether the node auto-repair is enabled for
  the node pool. If enabled, the nodes in this node pool will be
  monitored and, if they fail health checks too many times, an
  automatic repair action will be triggered.

##### management/upgrade_options
  Specifies the Auto Upgrade knobs for the node pool.

##### management/upgrade_options/auto_upgrade_start_time
Output only.  This field is set when upgrades are about to commence with the
  approximate start time for the upgrades, in RFC3339 text
  format.

##### management/upgrade_options/description
Output only.  This field is set when upgrades are about to commence with the
  description of the upgrade.

##### `cluster`

Required.  The cluster this node pool belongs to.

##### `zone`

Required.  The zone where the node pool is deployed


##### Output-only properties

* `version`: Output only.
  The version of the Kubernetes of this node.

#### `gcontainer_kube_config`

Generates a compatible Kuberenetes '.kube/config' file


#### Example

```puppet
# ~/.kube/config is used by Kubernetes client (kubectl)
gcontainer_kube_config { '/home/nelsona/.kube/config':
  ensure     => present,
  context    => "gke-mycluster-${cluster_id}",
  cluster    => "mycluster-${cluster_id}",
  zone       => 'us-central1-a',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

# A file named ~/.puppetlabs/etc/puppet/kubernetes is used by the
# garethr-kubernetes module.
gcontainer_kube_config { '/home/nelsona/.puppetlabs/etc/puppet/kubernetes.conf':
  ensure     => present,
  cluster    => "mycluster-${cluster_id}",
  zone       => 'us-central1-a',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### Reference

```puppet
gcontainer_kube_config { 'id-of-resource':
  cluster    => reference to gcontainer_cluster,
  context    => string,
  name       => string,
  zone       => string,
  project    => string,
  credential => reference to gauth_credential,
}
```

##### `name`

Required.  The config file kubectl settings will be written to.

##### `cluster`

Required.  A reference to Cluster resource

##### `zone`

Required.  The zone where the container is deployed

##### `context`

Required.  The name of the context. Defaults to cluster name.



### Bolt Tasks


#### `tasks/resize.rb`

  Resizes a cluster container node pool

This task takes inputs as JSON from standard input.

##### Arguments

  - `name`:
    The name of the node pool to resize

  - `cluster`:
    The name of the cluster that hosts the node pool

  - `size`:
    The new size of the container (in nodes)

  - `zone`:
    The zone that hosts the container

  - `project`:
    the project name where the cluster is hosted

  - `credential`:
    Path to a service account credentials file


## Limitations

This module has been tested on:

* RedHat 6, 7
* CentOS 6, 7
* Debian 7, 8
* Ubuntu 12.04, 14.04, 16.04, 16.10
* SLES 11-sp4, 12-sp2
* openSUSE 13
* Windows Server 2008 R2, 2012 R2, 2012 R2 Core, 2016 R2, 2016 R2 Core

Testing on other platforms has been minimal and cannot be guaranteed.

## Development

### Automatically Generated Files

Some files in this package are automatically generated by
[Magic Modules][magic-modules].

We use a code compiler to produce this module in order to avoid repetitive tasks
and improve code quality. This means all Google Cloud Platform Puppet modules
use the same underlying authentication, logic, test generation, style checks,
etc.

Learn more about the way to change autogenerated files by reading the
[CONTRIBUTING.md][] file.

### Contributing

Contributions to this library are always welcome and highly encouraged.

See [CONTRIBUTING.md][] for more information on how to get
started.

### Running tests

This project contains tests for [rspec][], [rspec-puppet][] and [rubocop][] to
verify functionality. For detailed information on using these tools, please see
their respective documentation.

#### Testing quickstart: Ruby > 2.0.0

```
gem install bundler
bundle install
bundle exec rspec
bundle exec rubocop
```

#### Debugging Tests

In case you need to debug tests in this module you can set the following
variables to increase verbose output:

Variable                | Side Effect
------------------------|---------------------------------------------------
`PUPPET_HTTP_VERBOSE=1` | Prints network access information by Puppet provier.
`PUPPET_HTTP_DEBUG=1`   | Prints the payload of network calls being made.
`GOOGLE_HTTP_VERBOSE=1` | Prints debug related to the network calls being made.
`GOOGLE_HTTP_DEBUG=1`   | Prints the payload of network calls being made.

During test runs (using [rspec][]) you can also set:

Variable                | Side Effect
------------------------|---------------------------------------------------
`RSPEC_DEBUG=1`         | Prints debug related to the tests being run.
`RSPEC_HTTP_VERBOSE=1`  | Prints network expectations and access.

[magic-modules]: https://github.com/GoogleCloudPlatform/magic-modules
[CONTRIBUTING.md]: CONTRIBUTING.md
[bundle-forge]: https://forge.puppet.com/google/cloud
[`google-gauth`]: https://github.com/GoogleCloudPlatform/puppet-google-auth
[rspec]: http://rspec.info/
[rspec-puppet]: http://rspec-puppet.com/
[rubocop]: https://rubocop.readthedocs.io/en/latest/
[`gcontainer_cluster`]: #gcontainer_cluster
[`gcontainer_node_pool`]: #gcontainer_node_pool
[`gcontainer_kube_config`]: #gcontainer_kube_config
