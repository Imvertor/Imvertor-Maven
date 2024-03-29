#!/bin/bash

JAR=$1
ARTIFACT=$2
JOBID=$3
PROPFILE=$4
OWNER=$5
REG=$6
ADORN=$7
PRGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
JVMPARAMS="-Xms512m -Xmx1024m -Dfile.encoding=UTF-8" 

echo Imvertor bin install folder: "$PRGDIR"

if [ -f "$JAVA_HOME/bin/java" ]; then
  JAVA=$JAVA_HOME/bin/java
else
  JAVA=/opt/java/openjdk/bin/java
fi

export PATH="$PATH:$PRGDIR/bin/EA"

export LANGUAGE=C.UTF-8
export LC_MONETARY=C.UTF-8
export LC_TIME=C.UTF-8
export LC_MESSAGES=C.UTF-8
export LANG=C.UTF-8
export LC_NUMERIC=C.UTF-8
export LC_ALL=C.UTF-8
export LC_COLLATE=C.UTF-8
export LC_CTYPE=C.UTF-8

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