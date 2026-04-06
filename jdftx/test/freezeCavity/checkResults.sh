#!/bin/bash

echo "7"

# Test 1: CANON baseline produces Shape file
if [ -f step1_canon.fluidShape ]; then echo "1 1 0 CANON Shape file dumped"; else echo "0 1 0 CANON Shape file dumped"; fi
awk '/IonicMinimize: Iter/ { E = $5 } END { print E, "-17.270 0.005 CANON baseline energy [Eh]" }' step1_canon.out

# Test 2: CANDLE with frozen cavity from CANON converges (no charge sloshing!)
awk '/Loading frozen cavity/ { found = 1 } END { print (found ? 1 : 0), "1 0 CANDLE freezeCavity loaded" }' step2_candle_frozen.out
awk '/Cavity will NOT be updated/ { found = 1 } END { print (found ? 1 : 0), "1 0 CANDLE freezeCavity message" }' step2_candle_frozen.out
awk '/IonicMinimize: Iter/ { E = $5 } END { print E, "-17.280 0.010 CANDLE frozen cavity energy [Eh]" }' step2_candle_frozen.out

# Test 3: GLSSA13 with frozen cavity converges too
awk '/Loading frozen cavity/ { found = 1 } END { print (found ? 1 : 0), "1 0 GLSSA13 freezeCavity loaded" }' step3_glssa13_frozen.out
awk '/IonicMinimize: Iter/ { E = $5 } END { print E, "-17.280 0.010 GLSSA13 frozen cavity energy [Eh]" }' step3_glssa13_frozen.out
