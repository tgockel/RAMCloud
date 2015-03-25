#####
## Note: Parameters below have comments next to them signifying the comma
## separated default for whether one wants to run SLIK's hashThroughput
## experiment or LookupExperiment.
## Hash,Lookup
####
# set TOTAL = total number of servers in config file
(( TOTAL=65 )) # 65,65

# set MIN = minimum number of indexlets
(( MIN_INDEXLET=1 )) # 1,1

# set MAX = maximum number of indexlets
(( MAX_INDEXLET= 10)) # 30,10

# set MAX = maximum number of clients
(( MAX_CLIENTS= 30)) # 30,30

# Number of concurrent operations the client should perform
(( CONCURRENT_OPS=20)) # 30,20

# Number of master servers per indexlet
(( SERVERS_PER_INDEXLET=2)) # 1,2

# Transport string, leave empty for infrc
TRANSPORT="" # "", "-T tcp"

# Number of objects to look up per operation
(( RANGE=1 ))
if [[ $1 != "" ]]
  then
  RANGE_OP="--numObjects=$1"
  RANGE=$1
else
  RANGE_OP="--numObjects=$RANGE"
fi


TIME="$(date +%Y%m%d%H%M%S)-is"
LOG_DIR="logs/$TIME"
mkdir -p "$LOG_DIR" > /dev/null

cp scripts/runIndexScalability.sh $LOG_DIR
cp scripts/clusterperf.py $LOG_DIR

echo "# Running with $CONCURRENT_OPS concurrent operations and " | tee -a "$LOG_DIR/console.log"
echo "# a batch size of $RANGE objs/operation" | tee -a "$LOG_DIR/console.log"
echo "# Generated by runIndexScalability.sh calling" | tee -a "$LOG_DIR/console.log"
echo "#              'clusterperf.py indexScalability'" | tee -a "$LOG_DIR/console.log"
echo "#"
echo "# numIndexlets  numServers   throughput(khashes/sec)     (kobjs/sec)   (avg latency us)     (numClients for max kobj/sec)" | tee -a "$LOG_DIR/console.log"
echo "#------------------------------------------------------------------------------------------------------------" | tee -a "$LOG_DIR/console.log"

for (( i=$MIN_INDEXLET; i<=$MAX_INDEXLET; i++ )) do
  # Number of servers required (excluding clients) for i indexlets
  (( SERVERS=$SERVERS_PER_INDEXLET*i))

  # Currently clients are set to occupy the remaining servers. To increase the number
  # of clients, increase the number of hosts in config file.
  (( CLIENTS=TOTAL-SERVERS ))
  if (( CLIENTS > MAX_CLIENTS))
  then
    ((CLIENTS = MAX_CLIENTS))
  else
    echo "Not enough servers allocated for the task. Please looking inside this script and modify the constants."
    exit
  fi

  # Give some time for the cluster to rest
  sleep 10

  # run clusterperf on for i indexlets
  scripts/clusterperf.py -i $i -n $CLIENTS --servers=$SERVERS $TRANSPORT indexScalability --count=$CONCURRENT_OPS $RANGE_OP --disjunct > "$LOG_DIR/$i.log"

  # extract max thoroughput for i indexlets
  grep -v '^#' logs/latest/client1\.* | grep -v '/.' | awk -v var="$i" -v numServ="$SERVERS" '$2>x{x=$2};$3>y{y=$3;z=$4;a=$1};END{print "\t"var"\t"numServ "\t"  x"\t"  y"\t" z"\t" a}' | tee -a "$LOG_DIR/console.log"

  # move latest dir to "i" dir in logs
  rm logs/$i 2>/dev/null
  mv logs/latest logs/$i

done

