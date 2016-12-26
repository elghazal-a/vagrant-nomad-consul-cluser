# /etc/nomad.d/client.hcl

datacenter = "dc1"
data_dir = "/tmp/nomad"

client {
  enabled = true
}

bind_addr = "0.0.0.0"