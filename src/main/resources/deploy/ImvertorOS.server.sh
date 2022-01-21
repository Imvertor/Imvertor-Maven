#!/bin/bash

JAR=$1
ARTIFACT=$2
JOBID=$3
PROPFILE=$4
OWNER=$5
REG=$6
ADORN=$7
PRGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
JVMPARAMS="-Xms512m -Xmx1024m" 

echo Imvertor bin install folder: "$PRGDIR"

export JAVA_HOME=$PRGDIR/bin/java/jdk8u312-b07-jreXX
if [ -f "$JAVA_HOME/bin/java" ]; then
  JAVA=$JAVA_HOME/bin/java
else
  JAVA=/opt/java/openjdk/bin/java
fi

export PATH="$PATH:$PRGDIR/bin/EA"

"$JAVA" $JVMPARAMS \
  -Dlog4j.configuration=file:$PRGDIR/log4j.properties \
  -Dinstall.dir="$PRGDIR" \
  -Drun.mode=deployed \
  -Downer.name="$OWNER" \
  -Djob.id="$JOBID" \
  -Dis.reg="$REG" \
  -Dversion.adornment="$ADORN" \
  -cp "$PRGDIR/bin/EA/eaapi.jar:$PRGDIR/bin/$JAR.jar" \
  nl.imvertor.$ARTIFACT \
  -arguments "$PROPFILE" \
  -owner "$OWNER"