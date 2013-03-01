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
    ("elasticsearch-configured").with(version: version, port: port, cluster_name: cluster_name), 
    ("elasticsearch-init-script")

  version.default("0.20.5")
  port.default("9200")
  cluster_name.default(`hostname`)

  met? {
    true
  }

end

dep("elasticsearch-extracted", :version) do
  requires_when_unmet ("elasticsearch-downloaded").with(version: version)

  def elasticsearch_home
    '/usr/local/elasticsearch'.p
  end

  def elasticsearch_tar_gz
    "/tmp/elasticsearch-#{version}.tar.gz".p
  end

  met? {
    elasticsearch_home.exists?
  }

  meet {
    shell "cd /tmp && tar -xvzf #{elasticsearch_tar_gz}"
    sudo "mv /tmp/elasticsearch-#{version} #{elasticsearch_home}"
    shell "cd -"
  }
end

dep("elasticsearch-downloaded", :version) do

  def elasticsearch_tar_gz
    "/tmp/elasticsearch-#{version}.tar.gz".p
  end

  met? {
    elasticsearch_tar_gz.exists?
  }

  meet {
    log_ok "Downloading ElasticSearch #{version} from elasticsearch.org"
    shell "cd /tmp && wget http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz ; cd -"
  }
end

dep("elasticsearch-configured",:version, :port, :cluster_name) do
  requires_when_unmet ("elasticsearch-extracted").with(version: version)

  def etc_elasticsearch
    '/etc/elasticsearch'.p
  end

  def elasticsearch_yml
    etc_elasticsearch / 'elasticsearch.yml'
  end

  def elasticsearch_home
    '/usr/local/elasticsearch'.p
  end  

  def tmp_elasticsearch_yml
    '/tmp/elasitcsearch.yml'.p
  end

  def original_elasticsearch_yml
    elasticsearch_home / 'elasticsearch.yml'
  end

  met? {
    elasticsearch_yml.exists?
  }

  meet {
    sudo "mkdir -p #{etc_elasticsearch}"

    original_content = original_elasticsearch_yml.read
    raise "Couldn't read content of '#{original_elasticsearch_yml}'!" if original_content.nil? or (original_elasticsearch_yml.strip.length <= 0)
    modified_content = original_content.gsub(/cluster\.name: elasticsearch/, "cluster.name: #{cluster_name}").gsub(/# http\.port: 9200/, "http.port: #{port}")

    tmp_elasticsearch_yml.open('w+') { | f | f.rint modified_content }

    sudo "mv #{tmp_elasticsearch_yml} #{elasticsearch_yml}"
  }
end

dep("elasticsearch-init-script") do
end
