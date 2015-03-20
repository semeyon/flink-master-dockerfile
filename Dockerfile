# Run on top of java 8
FROM dockerfile/java:oracle-java8
MAINTAINER Tobias Wiens <tobwiens@gmail.com>

# Install python 
RUN ["/bin/bash", "-c", "sudo apt-get update && sudo apt-get install python -y"]

# Variables for downloading
ENV FLINK_ARCHIVE_NAME flink-0.8.1-bin-hadoop1.tgz
ENV FLINK_DOWNLOAD_URL http://wwwftp.ciril.fr/pub/apache/flink/flink-0.8.1/
ENV FLINK_DIRECTORY /data/flink

# Go into data directory
WORKDIR /data

# Download flink and unzip it
RUN ["/bin/bash", "-c", "wget $FLINK_DOWNLOAD_URL$FLINK_ARCHIVE_NAME && \
mkdir -p $FLINK_DIRECTORY && \
tar -xf $FLINK_ARCHIVE_NAME -C $FLINK_DIRECTORY --strip-components=1 && \
rm -f $FLINK_ARCHIVE_NAME"]


# Cheap hack variables
ENV FLINK_JOBMANAGER_SCRIPT_TO_REPLACE 2>&1 < /dev/null &
ENV FLINK_JOBMANAGER_SCRIPT_REPLACE_WITH 2>&1 < /dev/null

RUN ["/bin/bash", "-c", "cat $FLINK_DIRECTORY/bin/jobmanager.sh | python -c \"import sys;print ''.join(map(lambda line: line.replace('$FLINK_JOBMANAGER_SCRIPT_TO_REPLACE', '$FLINK_JOBMANAGER_SCRIPT_REPLACE_WITH'), sys.stdin.readlines())); \" > $FLINK_DIRECTORY/bin/jobmanager-blocking.sh && \
chmod +x $FLINK_DIRECTORY/bin/jobmanager-blocking.sh"]

#Configuration variables
ENV FLINK_MASTER_PROPERTY jobmanager.rpc.address
ENV FLINK_MASTER_IP 10.0.1.1

# Replace jobmanager master IP-Address
RUN ["/bin/bash", "-c", "cat $FLINK_DIRECTORY/conf/flink-conf.yaml | python -c \"import sys;print ''.join(map(lambda line: '$FLINK_MASTER_PROPERTY: $FLINK_MASTER_IP' if '$FLINK_MASTER_PROPERTY' in line else line, sys.stdin.readlines())); \" > $FLINK_DIRECTORY/conf/flink-conf.yaml "]

# Start the jobmanager 
ENTRYPOINT ["/bin/bash", "-c", "$FLINK_DIRECTORY/bin/jobmanager-blocking.sh start cluster"]

