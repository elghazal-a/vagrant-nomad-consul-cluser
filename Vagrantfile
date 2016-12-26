# -*- mode: ruby -*-
# vi: set ft=ruby :


SERVER_COUNT = 1
AGENT_COUNT = 2

def serverIP(num)
  return "172.17.4.#{num+50}"
end

def agentIP(num)
  return "172.17.4.#{num+100}"
end


Vagrant.configure(2) do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
  
  config.vm.box = "debian/jessie64"


  config.vm.define "server1" do |server|
    PRIVATE_IP = serverIP(1)

    server.vm.network "forwarded_port", guest: 8500, host: 8500
    
    server.vm.hostname = "server1"
    server.vm.network :private_network, ip: "#{PRIVATE_IP}"

    server.vm.provision :shell, :privileged => true,
    inline: <<-EOF
    echo "PRIVATE_IP=#{PRIVATE_IP}" | tee /etc/environment
    EOF

    server.vm.provision :file, :source => "server/consul-server.service", :destination => "/tmp/consul.service"
    server.vm.provision :file, :source => "server/nomad-server.service", :destination => "/tmp/nomad.service"
    server.vm.provision :file, :source => "server/server.hcl", :destination => "/tmp/server.hcl"
    server.vm.provision :shell, :path => "server/bootstrap.sh", :privileged => true
  end

  (1..AGENT_COUNT).each do |i|
    config.vm.define vm_agent_name = "agent-%d" % i do |agent|

      agent.vm.hostname = vm_agent_name
      agent.vm.network :private_network, ip: agentIP(i)

      agent.vm.provision :shell, :privileged => true,
      inline: <<-EOF
      mkdir -p /etc/sysconfig
      echo "PRIVATE_IP=#{agentIP(i)}" | tee /etc/environment
      echo "SERVER_IP=#{serverIP(1)}" | tee /etc/sysconfig/consul
      echo "NODE_NAME=agent-#{i}" | tee -a /etc/sysconfig/consul
      EOF

      agent.vm.provision :file, :source => "agent/consul-agent.service", :destination => "/tmp/consul.service"
      agent.vm.provision :file, :source => "agent/nomad-agent.service", :destination => "/tmp/nomad.service"
      agent.vm.provision :file, :source => "agent/client.hcl", :destination => "/tmp/client.hcl"
      agent.vm.provision :shell, :path => "agent/bootstrap.sh", :privileged => true
    
    end
  end

end