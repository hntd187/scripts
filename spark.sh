#!/usr/bin/env bash

hadoop_configuration=true
s3a_fast_upload=true
s3a_max_connections=100
spark_output_committer="org.apache.spark.sql.parquet.DirectParquetOutputCommitter"

spark_config=true
spark_driver_memory="5g"
spark_eventdir="$HOME/spark_events"
spark_eventlog="true"
spark_default_parallelism="32"
spark_memory_fraction="0.8"

access_key=$AWS_ACCESS_KEY_ID
secret_key=$AWS_SECRET_ACCESS_KEY

spark_version="1.5.2"
spark_url="http://d3kbcqa49mib13.cloudfront.net/spark-$spark_version-bin-without-hadoop.tgz"

hadoop_version="2.7.1"
hadoop_url="http://apache.arvixe.com/hadoop/common/hadoop-$hadoop_version/hadoop-$hadoop_version.tar.gz"

java=false

while [[ $# > 0 ]]
do
i="$1"
  case $i in
    -h|--hadoop)
      echo "Hadoop version set to $2"
      hadoop_version="$2"
      shift
    ;;
    -s|--spark)
      echo "Spark version set to $2"
      spark_version="$2"
      shift
    ;;
    -a|--access)
      access_key="$2"
      shift
    ;;
    -k|--secret)
      secret_key="$2"
      shift
    ;;
    -j|--java)
      echo "Hit java."
      java=true
    ;;
    *)
      echo "Got unknown value: $1 = $2"
    ;;
  esac
  shift
done

if $java ; then
  yum=$(which yum)
  apt=$(which apt-get)
  brew=$(which brew)
  if [[ ! -z $apt ]]; then
    echo "OS: Debian Based, using Apt..."
    $apt --force-yes install openjdk-8-jdk > /dev/null
  elif [[ ! -z $yum ]]; then
    echo "OS: RHEL Based, using Yum..."
    $yum install -y java-1.8.0-openjdk > /dev/null
  elif [[ ! -z $brew ]]; then
    echo "OS: OSX Based, using Brew..."
    $brew install java > /dev/null
  else
    echo "No package manager detected, failed to install Java8"
    exit 1
  fi
fi

echo "Downloading Spark $spark_version..."
curl --progress -o $HOME/spark-$spark_version.tgz $spark_url
cd $HOME
[[ -d spark-$spark_version ]] || mkdir spark-$spark_version && tar xzf $HOME/spark-$spark_version.tgz -C spark-$spark_version --strip-components 1
echo -e "Extracting Spark $spark_version...\n"
cd spark-$spark_version

echo "Downloading Hadoop $hadoop_version..."
curl --progress -o ./hadoop-$hadoop_version.tar.gz $hadoop_url
echo -e "Extracting Hadoop $hadoop_version...\n"
[[ -d hadoop ]] || mkdir hadoop && tar xzf hadoop-$hadoop_version.tar.gz -C hadoop --strip-components 1

current_dir=$(pwd)
default_network=$(route | grep 'default' | awk '{if ($8 ~ /eth[0-9]+/){ print $8 }}')
ip=$(ifconfig $default_network | awk '{if ($1 ~ /^inet$/){ print $0 }}' | grep -o '[0-9\.]\+' | head -1)

# Default Core Site Conflicts with ours, so get rid of it.
# Also clean up left over archives.
[[ -d $current_dir/hadoop/etc/hadoop/core-site.xml ]] || rm $current_dir/hadoop/etc/hadoop/core-site.xml
rm $HOME/spark-$spark_version.tgz
rm hadoop-$hadoop_version.tar.gz

echo "Default network interface: $default_network"
echo -e "Default IP for SPARK_LOCAL_IP: $ip\n"

if $hadoop_configuration ; then
  echo -e "Configuring Hadoop...\n"
  echo "<configuration>" > $current_dir/conf/core-site.xml
  echo "<property>
    <name>fs.s3a.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>
  <property>
    <name>fs.s3a.fast.upload</name>
    <value>$s3a_fast_uploads</value>
  </property>
  <property>
    <name>fs.s3a.connection.maximum</name>
    <value>$s3a_max_connections</value>
  </property>
  <property>
    <name>spark.sql.parquet.output.committer.class</name>
    <value>$s3a_max_connections</value>
  </property>
  <property>
    <name>fs.s3a.access.key</name>
    <value>$access_key</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>$secret_key</value>
  </property>
  </configuration>" >> $current_dir/conf/core-site.xml
fi

echo -e "Creating Spark Environment Configuration...\n"
hadoop_path=$($current_dir/hadoop/bin/hadoop classpath)
echo "SPARK_CLASSPATH=\"$hadoop_path\"" > $current_dir/conf/spark-env.sh
echo "LD_LIBRARY_PATH=$current_dir/hadoop/lib/native" >> $current_dir/conf/spark-env.sh
echo "SPARK_LOCAL_IP=$ip" >> $current_dir/conf/spark-env.sh
chmod +x $current_dir/conf/spark-env.sh

if $spark_config ; then
  echo "Configuring Spark..."
  mkdir -p $spark_eventdir
  echo "spark.eventLog.enabled $spark_eventlog" > $current_dir/conf/spark-defaults.conf
  echo "spark.eventLog.dir $spark_eventdir" >> $current_dir/conf/spark-defaults.conf
  echo "spark.driver.memory $spark_driver_memory" >> $current_dir/conf/spark-defaults.conf
  echo "spark.executor.memory $spark_driver_memory" >> $current_dir/conf/spark-defaults.conf
  echo "spark.default.parallelism $spark_default_parallelism" >> $current_dir/conf/spark-defaults.conf
  echo "spark.memory.fraction $spark_memory_fraction" >> $current_dir/conf/spark-defaults.conf
fi

echo "$current_dir/bin/spark-shell --packages 'org.apache.hadoop:hadoop-aws:2.7.1,com.databricks:spark-csv_2.11:1.2.0'" >> $current_dir/spark_shell
chmod +x $current_dir/spark_shell

echo "All done, enjoy. :-)"
