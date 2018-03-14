#!/bin/bash

set -ex

df -h

# Environment

export CNI_VERSION=0.6.0
export KUBERNETES_VERSION=1.9.0

# SSH

mkdir -p /root/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDZ+EjzFUjxBLjJ2KfGxXVfqogLwmnmT5iHkdsn7ug7O23SioxAZj8kHrfOAQZuRMMTHzAlDcjBC2O7xXTFRdPVKLEy4oBw4jinqv0Csh7mXbz4IEqjaPS+JqGZH0cppszDTbOdjHtHJU6lIXtUFlkZQlqTurItmA+aSJBTh0mBPbIpEbRfIAj/7sDl5j6f5GhPMIsxoSxrikNj3lzz4B7fhAVpkB3IfFTiQuVX2VzRvAaVZOL+Uipz+LSpNXQtEpNiVcc55vZFKLpZ9pU3hMs067DFJZFB+yeXKqyGsSIBGo/fI0lXqV8aCMo7g07p5Z9VNDBXGv5W42q6f/+PF+n lukeaddison@Lukes-MacBook-Pro.local" > /root/.ssh/authorized_keys

# Tools
cd /kubernetes

yum update -y

yum install -y \
  ca-certificates \
  git \
  nfs-utils \
  net-tools \
  socat

yum clean all

# Worker
cd /kubernetes

cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=$ENVIRONMENT_FILE
ExecStart=/usr/local/bin/kubelet \\
  --allow-privileged=true \\
  --anonymous-auth=false \\
  --authorization-mode=Webhook \\
  --client-ca-file=/etc/kubernetes/pki/ca.pem \\
  --cgroup-driver systemd \\
  --cloud-provider= \\
  --cluster-dns=\${CLUSTER_DNS} \\
  --cluster-domain=cluster.local \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/etc/kubernetes/pki/kubelet.kubeconfig \\
  --network-plugin=cni \\
  --pod-cidr=\${POD_CIDR} \\
  --register-node=true \\
  --runtime-request-timeout=15m \\
  --tls-cert-file=/etc/kubernetes/pki/kubelet.pem \\
  --tls-private-key-file=/etc/kubernetes/pki/kubelet-key.pem \\
  --v=2 \\
  \$KUBELET_EXTRA_ARGS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

wget -q \
  https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-amd64-v${CNI_VERSION}.tgz \
  https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubelet

chmod +x kubelet

mkdir -p \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kubernetes \
  /var/run/kubernetes

tar -xvf cni-plugins-amd64-v${CNI_VERSION}.tgz -C /opt/cni/bin/

cp -a kubelet /usr/local/bin/
cp -a kubelet.service /etc/systemd/system

systemctl enable kubelet

# Finish

exit 0

