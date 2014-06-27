# Use last baseimage from ubuntu-12.04
FROM phusion/baseimage:0.9.9

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

###
### Added ruby 2.1
###
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6
RUN echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" > /etc/apt/sources.list.d/brightbox.list
RUN apt-get update

RUN apt-get install -y --no-install-recommends ruby2.1 ruby2.1-dev nodejs libxslt1.1 libpq5

RUN update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.1 171
RUN update-alternatives \
 --install /usr/bin/ruby ruby /usr/bin/ruby2.1 41 \
 --slave /usr/bin/erb erb /usr/bin/erb2.1 \
 --slave /usr/bin/testrb testrb /usr/bin/testrb2.1 \
 --slave /usr/bin/rake rake /usr/bin/rake2.1 \
 --slave /usr/bin/irb irb /usr/bin/irb2.1 \
 --slave /usr/bin/rdoc rdoc /usr/bin/rdoc2.1 \
 --slave /usr/bin/ri ri /usr/bin/ri2.1 \
 --slave /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby2.1.1.gz \
 --slave /usr/share/man/man1/erb.1.gz erb.1.gz /usr/share/man/man1/erb2.1.1.gz \
 --slave /usr/share/man/man1/irb.1.gz irb.1.gz /usr/share/man/man1/irb2.1.1.gz \
 --slave /usr/share/man/man1/rake.1.gz rake.1.gz /usr/share/man/man1/rake2.1.1.gz \
 --slave /usr/share/man/man1/ri.1.gz ri.1.gz /usr/share/man/man1/ri2.1.1.gz
RUN gem2.0 install rake bundler --no-rdoc --no-ri


###
### Add logstash-forwarder
###

# install deps
RUN apt-get install -y wget git golang ruby ruby-dev rubygems irb ri rdoc build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

# clone logstash-forwarder
RUN git clone git://github.com/elasticsearch/logstash-forwarder.git /tmp/logstash-forwarder
RUN cd /tmp/logstash-forwarder && go build

# Install fpm
RUN gem install fpm

# Build deb
RUN cd /tmp/logstash-forwarder && make deb
RUN dpkg -i /tmp/logstash-forwarder/logstash-forwarder_0.3.1_amd64.deb

# Cleanup
RUN rm -rf /tmp/*

# Add FIFO
RUN mkdir /tmp/feeds/ && mkfifo /tmp/feeds/fifofeed

ADD run.sh /usr/local/bin/run.sh
RUN chmod 755 /usr/local/bin/run.sh

RUN mkdir /opt/certs/
ADD certs/logstash-forwarder.crt /opt/certs/logstash-forwarder.crt
ADD certs/logstash-forwarder.key /opt/certs/logstash-forwarder.key






# ...put your own build instructions here...
# install service files for runit
ADD logstash.service /etc/service/logstash/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
