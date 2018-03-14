#!/bin/bash

set -ex

if [ ! -d "/kubernetes" ]; then
  exit 0
fi

# Environment

cd /kubernetes

ENVIRONMENT_FILE=/etc/kubernetes/environment.env

cat $ENVIRONMENT_FILE >> environment.env
cp -a environment.env $ENVIRONMENT_FILE

mkdir -p /etc/kubernetes

source $ENVIRONMENT_FILE
export $(cut -d= -f1 $ENVIRONMENT_FILE)

if [ -z "$HOSTNAME" ]; then
  /bin/hostname | awk '{print "HOSTNAME=" $1}' >> $ENVIRONMENT_FILE
fi
if [ -z "$IP" ]; then
  /sbin/ifconfig eth0 | grep 'inet ' | awk '{print "IP=" $2}' >> $ENVIRONMENT_FILE
fi
if [ -z "$ENCRYPTION_KEY" ]; then
  echo ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64) >> $ENVIRONMENT_FILE
fi
if [ -z "$ETCD_NAME" ]; then
  echo ETCD_NAME=$(hostname -s) >> $ENVIRONMENT_FILE
fi
if [ -z "$SERVICE_CLUSTER_IP_RANGE" ]; then
  echo SERVICE_CLUSTER_IP_RANGE=10.32.0.0/24 >> $ENVIRONMENT_FILE
fi
if [ -z "$CLUSTER_CIDR" ]; then
  echo CLUSTER_CIDR=10.200.0.0/16 >> $ENVIRONMENT_FILE
fi
if [ -z "$POD_CIDR" ]; then
  echo POD_CIDR=10.200.1.0/24 >> $ENVIRONMENT_FILE
fi
if [ -z "$USERS" ]; then
  echo 'USERS=( "root" "cent")' >> $ENVIRONMENT_FILE
fi
if [ -z "$CLUSTER_DNS" ]; then
  echo CLUSTER_DNS=10.32.0.10 >> $ENVIRONMENT_FILE
fi

source $ENVIRONMENT_FILE
export $(cut -d= -f1 $ENVIRONMENT_FILE)

if [ -z "$KUBERNETES_MASTER_IP" ]; then
  echo KUBERNETES_MASTER_IP=$IP >> $ENVIRONMENT_FILE
fi

source $ENVIRONMENT_FILE
export $(cut -d= -f1 $ENVIRONMENT_FILE)

# PKI
cd /kubernetes

cat > kubelet-csr.json <<EOF
{
  "CN": "system:node:${HOSTNAME}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:nodes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${HOSTNAME},${IP} \
  -profile=kubernetes \
  kubelet-csr.json | cfssljson -bare kubelet

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${KUBERNETES_MASTER_IP},10.32.0.1,127.0.0.1,kubernetes.default,kubernetes.default.svc.cluster.local \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

cp -a kubelet.pem kubelet-key.pem kubernetes.pem kubernetes-key.pem /etc/kubernetes/pki

# Etcd 

cd /kubernetes

mkdir -p /etc/etcd

cp -a kubernetes-key.pem kubernetes.pem /etc/etcd/

# Worker

cd /kubernetes

cat > 10-bridge.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

mkdir -p /etc/cni/net.d/
cp -a 10-bridge.conf /etc/cni/net.d/

# Configuration

cd /kubernetes

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

kubectl config set-cluster default \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_MASTER_IP}:6443 \
    --kubeconfig=kubelet.kubeconfig
kubectl config set-credentials system:node:${HOSTNAME} \
    --client-certificate=kubelet.pem \
    --client-key=kubelet-key.pem \
    --embed-certs=true \
    --kubeconfig=kubelet.kubeconfig
kubectl config set-context default \
    --cluster=default \
    --user=system:node:${HOSTNAME} \
    --kubeconfig=kubelet.kubeconfig
kubectl config use-context default --kubeconfig=kubelet.kubeconfig

kubectl config set-cluster default \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_MASTER_IP}:6443 \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config set-context default \
  --cluster=default \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

cp -a encryption-config.yaml kubelet.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/pki

# Admin

for USER in "${USERS[@]}"
do
  if [ "${USER}" == "root" ]; then
    KUBECONFIG="/root/.kube/config"
  else
    KUBECONFIG="/home/${USER}/.kube/config"
  fi

  kubectl config set-cluster default \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_MASTER_IP}:6443 \
    --kubeconfig ${KUBECONFIG}
  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --kubeconfig ${KUBECONFIG}
  kubectl config set-context default \
    --cluster=default \
    --user=admin \
    --kubeconfig ${KUBECONFIG}
  kubectl config use-context default \
    --kubeconfig ${KUBECONFIG}
  chown ${USER}:${USER} ${KUBECONFIG}
done

# DNS

cd /kubernetes

cat > kube-dns.yaml <<EOF
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "KubeDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: ${CLUSTER_DNS}
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  # replicas: not specified here:
  # 1. In order to make Addon Manager do not reconcile this replicas parameter.
  # 2. Default is 1.
  # 3. Will be tuned in real time if DNS horizontal auto-scaling is turned on.
  strategy:
    rollingUpdate:
      maxSurge: 10%
      maxUnavailable: 0
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
      volumes:
      - name: kube-dns-config
        configMap:
          name: kube-dns
          optional: true
      containers:
      - name: kubedns
        image: gcr.io/google_containers/k8s-dns-kube-dns-amd64:$DNS_VERSION
        resources:
          # TODO: Set memory limits when we've profiled the container for large
          # clusters, then set request = limit to keep this container in
          # guaranteed class. Currently, this container falls into the
          # "burstable" category so the kubelet doesn't backoff from restarting it.
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        livenessProbe:
          httpGet:
            path: /healthcheck/kubedns
            port: 10054
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /readiness
            port: 8081
            scheme: HTTP
          # we poll on pod startup for the Kubernetes master service and
          # only setup the /readiness HTTP server once that's available.
          initialDelaySeconds: 3
          timeoutSeconds: 5
        args:
        - --domain=cluster.local.
        - --dns-port=10053
        - --config-dir=/kube-dns-config
        - --v=2
        env:
        - name: PROMETHEUS_PORT
          value: "10055"
        ports:
        - containerPort: 10053
          name: dns-local
          protocol: UDP
        - containerPort: 10053
          name: dns-tcp-local
          protocol: TCP
        - containerPort: 10055
          name: metrics
          protocol: TCP
        volumeMounts:
        - name: kube-dns-config
          mountPath: /kube-dns-config
      - name: dnsmasq
        image: gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:$DNS_VERSION
        livenessProbe:
          httpGet:
            path: /healthcheck/dnsmasq
            port: 10054
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        args:
        - -v=2
        - -logtostderr
        - -configDir=/etc/k8s/dns/dnsmasq-nanny
        - -restartDnsmasq=true
        - --
        - -k
        - --cache-size=1000
        - --no-negcache
        - --log-facility=-
        - --server=/cluster.local/127.0.0.1#10053
        - --server=/in-addr.arpa/127.0.0.1#10053
        - --server=/ip6.arpa/127.0.0.1#10053
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        # see: https://github.com/kubernetes/kubernetes/issues/29055 for details
        resources:
          requests:
            cpu: 150m
            memory: 20Mi
        volumeMounts:
        - name: kube-dns-config
          mountPath: /etc/k8s/dns/dnsmasq-nanny
      - name: sidecar
        image: gcr.io/google_containers/k8s-dns-sidecar-amd64:$DNS_VERSION
        livenessProbe:
          httpGet:
            path: /metrics
            port: 10054
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        args:
        - --v=2
        - --logtostderr
        - --probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.cluster.local,5,SRV
        - --probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.cluster.local,5,SRV
        ports:
        - containerPort: 10054
          name: metrics
          protocol: TCP
        resources:
          requests:
            memory: 20Mi
            cpu: 10m
      dnsPolicy: Default  # Don't use cluster DNS.
      serviceAccountName: kube-dns
EOF

mkdir -p /etc/kubernetes/manifests
cp -a kube-dns.yaml /etc/kubernetes/manifests

# Clean up
#rm -Rf /kubernetes

exit 0
