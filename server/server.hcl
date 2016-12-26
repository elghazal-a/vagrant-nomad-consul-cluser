# /etc/nomad.d/server.hcl

data_dir = "/tmp/nomad"

server {
  enabled          = true
  bootstrap_expect = 1
}

bind_addr = "0.0.0.0"

advertise {
  http = "172.17.4.51"
  rpc  = "172.17.4.51"
  serf = "172.17.4.51"
}


