#!/bin/env sh

SAMPLEFOLDER=samples
SAMPLEIN=$(find . -name '*.frag' -o \( -name '*.decaf' \))

for SAMPLE in $SAMPLEIN; do
    rm -f out
    EXPECTEDOUT=$(echo "$SAMPLE" | sed -e "s/\.frag/\.out/g" | sed -e "s/\.decaf/\.out/g" )

    ./dcc < $SAMPLE > out 2>&1
    cmp --silent out $EXPECTEDOUT || echo "Test failed for output $EXPECTEDOUT"
done
