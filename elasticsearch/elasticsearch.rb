dep("elasticsearch-running", :version, :port, :cluster_name) do
  requires_when_unmet ("elasticsearch-installed").with(version: version, port: port, cluster_name: cluster_name)

  version.default("0.20.5")
  port.default("9200")
  cluster_name.default(`hostname`)

  met? {
    shell "curl http://localhost:#{port}"
  }

  meet {
    sudo "/etc/init.d/elasticsearch start"
  }
end

dep("elasticsearch-installed", :version, :port, :cluster_name) do
  requires ("elasticsearch-extracted").with(version: version), 
    ("elasticsearch-configured").with(port: port, cluster_name: cluster_name), 
    ("elasticsearch-init-script")

  version.default("0.20.5")
  port.default("9200")
  cluster_name.default(`hostname`)

  met? {
    true
  }

end

dep("elasticsearch-extracted", :version) do
  requires_when_unmet Dep("elasticsearch-downloaded").with(version: version)

  def elasticsearch_home
    '/usr/local/elasticsearch'.p
  end

  met? {
    elasticsearch_home.exists?
  }

end

dep("elasticsearch-downloaded", :version) do

  def elasticsearch_tar_gz
    '/tmp/elasticsearch-#{version}.tar.gz'.p
  end

  met? {
    elasticsearch_tar_gz.exists?
  }

  meet {
    shell "cd /tmp && wget http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz ; cd -"
  }
end

dep("elasticsearch-configured", :port, :cluster_name) do
end

dep("elasticsearch-init-script") do
end
