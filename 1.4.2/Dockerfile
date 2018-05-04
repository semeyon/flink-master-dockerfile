# Run on top of java 8
FROM java:openjdk-8-jdk
MAINTAINER Semeyon Svetliy <https://github.com/semeyon/flink-master-dockerfile>

# Install python and git and net-tools (ifconfig)
RUN ["/bin/bash", "-c", "apt-get update && apt-get install python git net-tools -y"]

# Variables for downloading
ENV FLINK_VERSION "flink-1.4.2"
ENV FLINK_ARCHIVE_NAME "$FLINK_VERSION-bin-hadoop28-scala_2.11.tgz"
ENV FLINK_CONF_FILE "/opt/flink/conf/flink-conf.yaml"
ENV FLINK_DOWNLOAD_URL "http://apache-mirror.rbc.ru/pub/apache/flink/$FLINK_VERSION/$FLINK_ARCHIVE_NAME"
ENV FLINK_DIRECTORY /data/flink


# Default variables
ENV FLINK_MASTER_PROPERTY jobmanager.rpc.address
# ENV FLINK_MASTER_IP 0.0.0.0

ENV AKKA_FRAMESIZE akka.framesize
ENV AKKA_FRAMESIZE_VAl 20971520b

# Go into data directory
RUN mkdir data
# RUN mkdir /var/log/flink
WORKDIR /data

# Install string replace tool - available through "replace-string"
RUN ["/bin/bash", "-c", "git clone https://github.com/tobwiens/python-replace-string-in-pipe.git && \
ln -s /data/python-replace-string-in-pipe/replace-string.py /usr/local/bin/replace-string && \
 chmod +x /usr/local/bin/replace-string"]

# Install yaml config file change tool
RUN ["/bin/bash", "-c", "git clone https://github.com/tobwiens/yaml-change-attribute.git && \
 ln -s /data/yaml-change-attribute/yaml-change.py /usr/local/bin/yaml-change && \
 chmod +x /usr/local/bin/yaml-change"]

# Download flink and unzip it
RUN ["/bin/bash", "-c", "wget $FLINK_DOWNLOAD_URL && \
mkdir -p $FLINK_DIRECTORY && \
tar -xf $FLINK_ARCHIVE_NAME -C $FLINK_DIRECTORY --strip-components=1 && \
rm -f $FLINK_ARCHIVE_NAME"]

ADD ./1.4.2/start-flink-master.sh /data/start-flink-master.sh
RUN chmod +x /data/start-flink-master.sh

EXPOSE 6123

WORKDIR ${FLINK_DIRECTORY}/bin
# Start the jobmanager
ENTRYPOINT ["/data/start-flink-master.sh"]
