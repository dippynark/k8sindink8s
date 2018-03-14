FROM centos:7.3.1611

LABEL maintainer="luke.addison@jetstack.io"

# tell systemd we are in a container
ENV container docker

# install systemd
RUN yum -y update && yum -y install \
  systemd \
  initscripts

# remove default startup services
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*; \
  rm -f /etc/systemd/system/*.wants/*; \
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*; \
  rm -f /lib/systemd/system/anaconda.target.wants/*;

# configure IP forwarding
RUN echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/10-sysctl.conf && \
  sysctl -p

# install docker
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
  yum install -y --setopt=obsoletes=0 \
    docker-ce-17.03.1.ce-1.el7.centos \
    docker-ce-selinux-17.03.1.ce-1.el7.centos && \
  systemctl enable docker

# clean
RUN yum clean all

VOLUME /var/lib/docker
CMD ["/usr/sbin/init"]
