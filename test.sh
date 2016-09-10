#!/bin/sh

SAMPLEIN=$(find . -name '*.frag' -o \( -name '*.decaf' \))

for SAMPLE in $SAMPLEIN; do
    EXPECTEDOUT=$(echo "$SAMPLE" | sed -e "s/\.frag/\.out/g" | sed -e "s/\.decaf/\.out/g" )

    rm -f out
    ./dcc < $SAMPLE > out 2>&1
    cmp --silent out $EXPECTEDOUT || echo "Test failed for output $EXPECTEDOUT"
    rm out
done
