name 'sloeinfra'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures sloeinfra'
version '0.1.0'
chef_version '>= 14.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/sloeinfra/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/sloeinfra'

depends 'conntrack', '~> 0.2.2'
depends 'docker'
depends 'etcd'
depends 'minikube', '~> 0.1.1'
depends 'nodejs', '~> 6.0.0'
depends 'vagrant', '~> 2.0.1'
