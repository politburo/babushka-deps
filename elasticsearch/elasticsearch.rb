dep("elasticsearch-running", :version, :port, :cluster_name) do
  requires_when_unmet Dep("elasticsearch-installed").with(version: version, port: port, cluster_name: cluster_name)

  version.default("0.20.5")
  port.default(9200)
  cluster_name.default(`hostname`)

  met? {
    shell "curl http://localhost:#{port}"
  }

  meet {
    sudo "/etc/init.d/elasticsearch start"
  }
end

dep("elasticsearch-installed", :version, :port, :cluster_name) do
  requires Dep("elasticsearch-extracted").with(version: version), Dep("elasticsearch-configured").with(port: port, cluster_name: cluster_name), Dep("elasticsearch-init-script")

  version.default("0.20.5")
  port.default(9200)
  cluster_name.default(`hostname`)

  met? {
    true
  }

end

dep("elasticsearch-extracted", :version) do

  def elasticsearch_home
    path '/usr/local/elasticsearch'
  end

  met? {
    elasticsearch_home.exists?
  }
end
