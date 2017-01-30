FROM ubuntu:16.04
MAINTAINER tarbase <hello@tarbase.com>

# Install the pritunl repository and public key (CF8E292A)
RUN echo "deb http://repo.pritunl.com/stable/apt xenial main" > /etc/apt/sources.list.d/pritunl.list &&\
    apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A

# Update the package catalog and upgrade any existing packages
RUN apt-get update -q &&\
    apt-get upgrade -y -q

# Install the pritunl package
RUN apt-get -y install pritunl

# Don't forget to cleanup after our ourselves
RUN apt-get clean &&\
    apt-get -y -q autoclean &&\
    apt-get -y -q autoremove &&\
    rm -rf /tmp/*

# Install dumb-init
# We need to install wget to fetch the file (curl needs more space that wget)
RUN apt-get install -y wget &&\
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 &&\
    chmod +x /usr/local/bin/dumb-init

# Copy the init script from the local repository to the docker image
COPY bin/start-pritunl.sh /usr/bin/start-pritunl.sh

# Expose pritunl ports; 1194 (udp) for VPN traffic, 443 for admin interface
EXPOSE 1194
EXPOSE 443
EXPOSE 80

# Set the dumb-init as the entrypoint for the container
# and pass the start-pritunl script as the argument
ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/usr/bin/start-pritunl.sh"]

# Send pritunl logs to stdout
CMD ["/usr/bin/tail", "-f", "/var/log/pritunl.log"]
