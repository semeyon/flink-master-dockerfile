# Run on top of java 8
FROM dockerfile/java:oracle-java8
MAINTAINER Tobias Wiens <tobwiens@gmail.com>

# Install python and git
RUN ["/bin/bash", "-c", "sudo apt-get update && sudo apt-get install python git -y"]

# Variables for downloading
ENV FLINK_ARCHIVE_NAME flink-0.8.1-bin-hadoop1.tgz
ENV FLINK_DOWNLOAD_URL http://wwwftp.ciril.fr/pub/apache/flink/flink-0.8.1/
ENV FLINK_DIRECTORY /data/flink

# Go into data directory
WORKDIR /data

# Install string replace tool - available through "replace-string"
RUN ["/bin/bash", "-c", "git clone https://github.com/tobwiens/python-replace-string-in-pipe.git && \
sudo ln -s /data/python-replace-string-in-pipe/replace-string.py /usr/local/bin/replace-string && \
sudo chmod +x /usr/local/bin/replace-string"]

# Install yaml config file change tool
RUN ["/bin/bash", "-c", "git clone https://github.com/tobwiens/yaml-change-attribute.git && \
sudo ln -s /data/yaml-change-attribute/yaml-change.py /usr/local/bin/yaml-change && \
sudo chmod +x /usr/local/bin/yaml-change"]

# Download flink and unzip it
RUN ["/bin/bash", "-c", "wget $FLINK_DOWNLOAD_URL$FLINK_ARCHIVE_NAME && \
mkdir -p $FLINK_DIRECTORY && \
tar -xf $FLINK_ARCHIVE_NAME -C $FLINK_DIRECTORY --strip-components=1 && \
rm -f $FLINK_ARCHIVE_NAME"]

# Cheap hack variables - replacement in jobmanager.sh (remove the & to not run in the background)

ENV FLINK_JOBMANAGER_SCRIPT_TO_REPLACE 2>&1 < /dev/null &
ENV FLINK_JOBMANAGER_SCRIPT_REPLACE_WITH 2>&1 < /dev/null

RUN ["/bin/bash", "-c", "cat $FLINK_DIRECTORY/bin/jobmanager.sh | replace-string \"$FLINK_JOBMANAGER_SCRIPT_TO_REPLACE\" \"$FLINK_JOBMANAGER_SCRIPT_REPLACE_WITH\" > $FLINK_DIRECTORY/bin/jobmanager-blocking.sh && \
chmod +x $FLINK_DIRECTORY/bin/jobmanager-blocking.sh"]

#Configuration variables
ENV FLINK_MASTER_PROPERTY jobmanager.rpc.address
ENV FLINK_MASTER_IP 10.0.1.1

# Replace jobmanager master IP-Address
RUN ["/bin/bash", "-c", "cat $FLINK_DIRECTORY/conf/flink-conf.yaml | yaml-change $FLINK_MASTER_PROPERTY $FLINK_MASTER_IP > $FLINK_DIRECTORY/conf/flink-conf-new.yaml && \
/bin/cp $FLINK_DIRECTORY/conf/flink-conf-new.yaml $FLINK_DIRECTORY/conf/flink-conf.yaml && \
rm $FLINK_DIRECTORY/conf/flink-conf-new.yaml"]

# Start the jobmanager 
CMD ["/bin/bash", "-c", "$FLINK_DIRECTORY/bin/jobmanager-blocking.sh start cluster"]

