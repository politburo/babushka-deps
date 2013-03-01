dep("elasticsearch-running", :port, :cluster_name) do
  requires_if_unmet "elasticsearch-installed"

  port.default(9200)
  cluster_name.default(`hostname`)

  met? {
    shell "curl http://localhost:#{port}"
  }

  meet {
    sudo "/etc/init.d/elasticsearch start"
  }
end