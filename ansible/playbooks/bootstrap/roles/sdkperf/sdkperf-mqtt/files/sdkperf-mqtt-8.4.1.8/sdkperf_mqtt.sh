#!/bin/sh
# ---------------------------------------------
#
# Solace Systems sdkperf_java startup script.
#
# --------------------------------------------- 


# ---------------------------------------------
# Start of user customizable properties
# ---------------------------------------------
SOLACE_VM_ARGS=
# To enable cpu usage, set the SOLACE_SDKPERF_CPU_USAGE environment variable
# or force the SOLACE_VM_ARGS update.
[ -z $SOLACE_SDKPERF_CPU_USAGE ] || \
SOLACE_VM_ARGS="$SOLACE_VM_ARGS -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# To use a non-default Kerberos library, set the SOLACE_SDKPERF_KRB_LIB environment variable 
# or force the SOLACE_VM_ARGS update.
[ -z $SOLACE_SDKPERF_KRB_LIB ] || \
SOLACE_VM_ARGS="$SOLACE_VM_ARGS -Dsun.security.jgss.native=true -Djavax.security.auth.useSubjectCredsOnly=false -Dsun.security.jgss.lib=$SOLACE_SDKPERF_KRB_LIB"

# To use a non-default Kerberos configuration file, set the SOLACE_SDKPERF_KRB_CONF environment variable 
# or force the SOLACE_VM_ARGS update.
[ -z $SOLACE_SDKPERF_KRB_CONF ] || \
SOLACE_VM_ARGS="$SOLACE_VM_ARGS -Djava.security.krb5.conf=$SOLACE_SDKPERF_KRB_CONF"

# To use a non-default JAAS configuration file, set the SOLACE_SDKPERF_JAAS_CONF environment variable 
# or force the SOLACE_VM_ARGS update.
[ -z $SOLACE_SDKPERF_JAAS_CONF ] || \
SOLACE_VM_ARGS="$SOLACE_VM_ARGS -Djava.security.auth.login.config=$SOLACE_SDKPERF_JAAS_CONF"
if [[ "$*" =~ "-as=kerberos" ]]; then
    [ -z $SOLACE_SDKPERF_JAAS_CONF ] && \
    SOLACE_VM_ARGS="$SOLACE_VM_ARGS -Djava.security.auth.login.config=./jaas/login.conf"
fi

# To customize VM memory, set the SOLACE_SDKPERF_VM_MEM environment variable.
[ "$SOLACE_SDKPERF_VM_MEM" ] || SOLACE_SDKPERF_VM_MEM="-Xms512m -Xmx1024m"
SOLACE_VM_ARGS="$SOLACE_VM_ARGS $SOLACE_SDKPERF_VM_MEM"

# ---------------------------------------------
# End of user customizable properties
# ---------------------------------------------


PROGRAM_DIR=`dirname "$0"`
cd "$PROGRAM_DIR"

for FILE in ./lib/*.jar; do
        CLASSPATH="$CLASSPATH":"$FILE"
done

# Enabling Log4J logging as configured in lib/optional/log4j.properties
# Uncomment line below to enable
SOLACE_ENABLE_LOG4J=1
if [[ $SOLACE_ENABLE_LOG4J -eq 1 ]]; then
        for FILE in ./lib/optional/*.jar; do
                CLASSPATH="$CLASSPATH":"$FILE"
        done
        CLASSPATH="$CLASSPATH":./lib/optional/
fi
echo CLASSPATH: $CLASSPATH
echo JAVA: `which java`
echo SOLACE_VM_ARGS: $SOLACE_VM_ARGS

# Add $JMX to java command line below for cpu usage.
CLASSPATH="$CLASSPATH" java $SOLACE_VM_ARGS com.solacesystems.pubsub.sdkperf.SDKPerf_java -api=MQTT "$@"
