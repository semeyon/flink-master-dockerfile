#!/usr/bin/env bash
set -x
#Replace the FLINK_MASTER_PROPERTY=jobmanager.rpc.address with FLINK_MASTER_IP(default=127.0.0.1)
FLINK_MASTER_IP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
cat $FLINK_DIRECTORY/conf/flink-conf.yaml \
| yaml-change $FLINK_MASTER_PROPERTY $FLINK_MASTER_IP > $FLINK_DIRECTORY/conf/flink-conf-new.yaml && \
/bin/cp $FLINK_DIRECTORY/conf/flink-conf-new.yaml $FLINK_DIRECTORY/conf/flink-conf.yaml && \
rm $FLINK_DIRECTORY/conf/flink-conf-new.yaml

# Start the web client
$FLINK_DIRECTORY/bin/start-webclient.sh

# Start the flink cluster
# jobmanager.sh start cluster batch
$FLINK_DIRECTORY/bin/jobmanager.sh start cluster batch

# Don't stop the container
sleep infinity