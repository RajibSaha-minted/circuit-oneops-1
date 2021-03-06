include_pack "lbdb"

name "postgresql-governor"
description "Governor based PostgreSQL"
type "Platform"
category "Database Relational SQL"

platform :attributes => {'autoreplace' => 'false'}

resource "secgroup",
         :cookbook => "oneops.1.secgroup",
         :design => true,
         :attributes => {
             "inbound" => '[ "22 22 tcp 0.0.0.0/0", "5432 5432 tcp 0.0.0.0/0", "2379 2379 tcp 0.0.0.0/0", "2380 2380 tcp 0.0.0.0/0", "5000 5000 tcp 0.0.0.0/0", "15432 15432 tcp 0.0.0.0/0" ]'
         },
         :requires => {
             :constraint => "1..1",
             :services => "compute"
         }

resource "postgresql-governor",
  :cookbook => "oneops.1.postgresql-governor",
  :design => true,
  :requires => { "constraint" => "1..1" },
  :attributes => {
      
                 },
  :monitors => {
      'Replicators' =>  { 
        :enable => 'false',
        :description => 'replicator count - sender or receiver',
        :source => '',
        :chart => {'min'=>0, 'unit'=>''},
        :cmd => 'check_replicators',
        :cmd_line => '/opt/nagios/libexec/check_replicators.sh',
        :metrics =>  {
                    'replicators'   => metric( 
                       :unit => '', 
                       :description => 'Replicator count - sender or receiver', 
                       :dstype => 'GAUGE',
                       :display_group => "Replicators"),
                       
                  },
                  :thresholds => {
                  }
                },
      'Backups' =>  { 
        :enable => 'false',
        :description => 'Backup file count. options: user_host path min_back filter',
        :source => '',
        :cmd_options => {
           :user_host => '',
           :path => '/share/backup',
           :min_back => '1440',
           :filter => ''
        },
        :chart => {'min'=>0, 'unit'=>''},
        :cmd => 'check_backups!#{cmd_options[:user_host]}!#{cmd_options[:path]}!#{cmd_options[:min_back]}!#{cmd_options[:filter]}',
        :cmd_line => '/opt/nagios/libexec/check_backups.sh $ARG1$ $ARG2$ $ARG3$ $ARG4$',
        :metrics =>  {
                    'backup_count'   => metric( 
                       :unit => '', 
                       :description => 'backup count', 
                       :dstype => 'GAUGE',
                       :display_group => "Backups"),
                       
                  },
                  :thresholds => {
                  }
                },                
      'PostgresStats' =>  { 
	              :description => 'default metrics',
                  :source => '',
                  :chart => {'min'=>0, 'unit'=>''},
                  :cmd => 'check_postgresql_stats',
                  :cmd_line => '/opt/nagios/libexec/check_sql_pg.rb /etc/nagios3/pg_stats.yaml',
                  :metrics =>  {
                    'active_queries'   => metric( 
          					   :unit => '', 
          					   :description => 'Active Queries', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Queries"),
                    'locks'   => metric( 
          					   :unit => '', 
          					   :description => 'Locks', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Locks"),
                    'wait_locks'   => metric( 
          					   :unit => '', 
          					   :description => 'Wait Locks', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Locks"),
                    'heap_hit'   => metric( 
          					   :unit => 'B', 
          					   :description => 'Heap Hit', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Heap"),
                    'heap_read'   => metric( 
          					   :unit => 'B', 
          					   :description => 'Heap Read', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Heap"),
                    'heap_hit_ratio'   => metric( 
          					   :unit => '%', 
          					   :description => 'Heap Hit Ratio', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Heap"),
                    'index_read'   => metric( 
          					   :unit => 'B', 
          					   :description => 'Index Read', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Index"),
                    'index_hit'   => metric( 
          					   :unit => 'B', 
          					   :description => 'Index Hit', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Index"),
                    'index_hit_ratio'   => metric( 
          					   :unit => '%', 
          					   :description => 'Index Hit Ratio', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Index"),
                    'disk_usage'   => metric( 
          					   :unit => 'B', 
          					   :description => 'Disk Usage', 
          					   :dstype => 'GAUGE',
          					   :display_group => "Storage"),
                  },
                  :thresholds => {
                  }
                }
             },
  :payloads => { 'master' => {
      'description' => 'Master DB', 
      'definition' => '{ 
         "returnObject": false, 
         "returnRelation": false, 
         "relationName": "base.RealizedAs", 
         "direction": "to", 
         "relationAttrs":[{"attributeName":"priority", "condition":">", "avalue":"1"}],
         "relations": [ 
           { "returnObject": false, 
             "returnRelation": false, 
             "relationName": "manifest.Requires", 
             "direction": "to",
             "targetClassName": "manifest.Platform", 
             "relations": [ 
               { "returnObject": false,
                 "returnRelation": false,
                 "relationName": "manifest.Entrypoint",
                 "direction": "from",
                 "relations": [
                   {"returnObject": false,
                   "returnRelation": false,
                   "relationName": "manifest.DependsOn",
                   "direction": "from",
                   "relations": [ 
                     { "returnObject": true, 
                       "returnRelation": false, 
                       "relationName": "base.RealizedAs", 
                       "direction": "from",
                       "relationAttrs":[{"attributeName":"priority", "condition":"eq", "avalue":"1"}]
                     }
                    ]
                   }  
                 ]
               }
             ]
           } 
         ] 
      }'  
    },
 'master_redundant' => {
      'description' => 'Master DB in redundant mode', 
      'definition' => '{ 
         "returnObject": false, 
         "returnRelation": false, 
         "relationName": "base.RealizedAs", 
         "direction": "to", 
         "relationAttrs":[{"attributeName":"priority", "condition":">", "avalue":"1"}],
         "relations": [ 
           { "returnObject": false, 
             "returnRelation": false, 
             "relationName": "manifest.Requires", 
             "direction": "to",
             "targetClassName": "manifest.Platform", 
             "relations": [ 
               { "returnObject": false,
                 "returnRelation": false,
                 "relationName": "manifest.Entrypoint",
                 "direction": "from",
                 "relations": [
                   {"returnObject": false,
                   "returnRelation": false,
                   "relationName": "manifest.DependsOn",
                   "direction": "from",
                   "relations": [ 
                     { "returnObject": false, 
                       "returnRelation": false, 
                       "relationName": "manifest.DependsOn", 
                       "direction": "from",
                       "targetClassName": "manifest.oneops.1.Compute",                            
                       "relations": [ 
                         { "returnObject": true, 
                           "returnRelation": false, 
                           "relationName": "base.RealizedAs", 
                           "targetClassName": "bom.oneops.1.Compute",                            
                           "direction": "from",
                           "relationAttrs":[{"attributeName":"priority", "condition":"eq", "avalue":"1"}]
                         }
                        ]                       
                     }
                    ]
                   }  
                 ]
               }
             ]
           } 
         ] 
      }'  
    }
  }
    
resource "artifact",
  :cookbook => "oneops.1.artifact",
  :design => true,
  :requires => { "constraint" => "0..*" },
  :attributes => {

  }

resource "hostname",
  :cookbook => "oneops.1.fqdn",
  :design => true,
  :requires => {
    :constraint => "1..1",
    :services => "dns",
    :help => "optional hostname dns entry"
  },
  :attributes => {
    :ptr_enabled => "true",
    :ptr_source => "instance"
  }

resource "etcd",
  :cookbook => "oneops.1.etcd",
  :design => true,
  :requires => { "constraint" => "1..1" },
  :attributes => {
    :version => "3.0.1"
}

resource "haproxy",
  :cookbook => "oneops.1.haproxy",
  :design => true,
  :requires => { "constraint" => "1..1" },
  :attributes => {
     :enable_stats_socket => false,
     :enable_stats_web => false,
     :lbmethod => 'roundrobin',
     :lbmode => 'tcp',
     :listeners => "{\"5000\":\"5432\"}",
     :options => "[\"httpchk GET\"]",
     :check_port => '15432'
}

resource "lb",
  :except => [ 'single' ],
  :design => true,
  :cookbook => "oneops.1.lb",
  :requires => { "constraint" => "1..1", "services" => "compute,lb,dns" },
  :attributes => {
    "listeners" => '["tcp 5432 tcp 5000","tcp 2379 tcp 2379"]',
  },
  :payloads => {
    'primaryactiveclouds' => {
        'description' => 'primaryactiveclouds',
        'definition' => '{
        "returnObject": false,
        "returnRelation": false,
        "relationName": "base.RealizedAs",
        "direction": "to",
        "targetClassName": "manifest.Lb",
        "relations": [
        { "returnObject": false,
            "returnRelation": false,
            "relationName": "manifest.Requires",
            "direction": "to",
            "targetClassName": "manifest.Platform",
            "relations": [
            { "returnObject": false,
                "returnRelation": false,
                "relationAttrs":[{"attributeName":"priority", "condition":"eq", "avalue":"1"},
                {"attributeName":"adminstatus", "condition":"neq", "avalue":"offline"}],
                "relationName": "base.Consumes",
                "direction": "from",
                "targetClassName": "account.Cloud",
                "relations": [
                { "returnObject": true,
                    "returnRelation": false,
                    "relationAttrs":[{"attributeName":"service", "condition":"eq", "avalue":"lb"}],
                    "relationName": "base.Provides",
                    "direction": "from",
                    "targetClassName": "cloud.service.Netscaler"
                }
                ]
            }
            ]
        }
        ]
    }'
  }
}

[ 'postgresql-governor' ].each do |from|
  relation "#{from}::depends_on::volume",
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'volume',
    :attributes    => { "flex" => false, "min" => 1, "max" => 1 } 
end

# postgresql cookbook needs to re-run when primary and second clouds are flipped.
# this propagation rule will trigger the re-run of postgresql cookbook
# when fqdn (progagate to lb and hostname) is replaced or updated.
[ 'postgresql-governor' ].each do |from|
    relation "#{from}::depends_on::hostname",
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'hostname',
    :attributes    => { "propagate_to" => 'from', "flex" => false, "min" => 1, "max" => 1 }
end

#[ 'postgresql-governor' ].each do |from|
#    relation "#{from}::depends_on::etcd",
#    :relation_name => 'DependsOn',
#    :from_resource => from,
#    :to_resource   => 'etcd',
#    :attributes    => { "flex" => false, "min" => 1, "max" => 1 }
#end

[ 'etcd' ].each do |from|
    relation "#{from}::depends_on::hostname",
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'hostname',
    :attributes    => { "flex" => false, "min" => 1, "max" => 1 }
end

[ 'haproxy' ].each do |from|
    relation "#{from}::depends_on::hostname",
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'hostname',
    :attributes    => { "flex" => false, "min" => 1, "max" => 1 }
end

# propagation rule for replace
[ 'hostname' ].each do |from|
    relation "#{from}::depends_on::compute",
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { "propagate_to" => 'from', "flex" => false, "min" => 1, "max" => 1 }
end

[ 'database' ].each do |from|
  relation "#{from}::depends_on::postgresql-governor",
  :relation_name => 'DependsOn',
  :from_resource => from,
  :to_resource   => 'postgresql-governor',
  :attributes    => { "flex" => false, "min" => 1, "max" => 1 } 
end

# depends_on

[ 'lb' ].each do |from|
    relation "#{from}::depends_on::compute",
    :only => [ 'redundant' ],
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { "propagate_to" => 'both', "flex" => true, "current" =>3, "min" => 3, "max" => 10}
end

# -d name due to pack sync logic uses a map keyed by that name - it doesnt get put into cms
[ 'lb' ].each do |from|
    relation "#{from}::depends_on::compute-d",
    :only => [ '_default' ],
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { "flex" => false }
end

# managed_via
[ 'postgresql-governor','etcd', 'haproxy', 'artifact' ].each do |from|
  relation "#{from}::managed_via::compute",
    :except => [ '_default' ],
    :relation_name => 'ManagedVia',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { } 
end
