#!/bin/bash

echo "11"

# Neutral CANON tests
awk '/IonicMinimize: Iter/ { E = $5 } END { print E, "-17.270 0.005 Neutral CANON energy [Eh]" }' neutral.out
awk '/Nonlinear solve completed after/ { found = 1 } END { print (found ? 1 : 0), "1 0 Neutral CANON nonlinear solver" }' neutral.out
if grep -q 'E_Zcenter' neutral.fluidDebug; then echo "1 1 0 Neutral CANON debug E_Zcenter"; else echo "0 1 0 Neutral CANON debug E_Zcenter"; fi
if grep -q 'E_Res' neutral.fluidDebug; then echo "1 1 0 Neutral CANON debug E_Res"; else echo "0 1 0 Neutral CANON debug E_Res"; fi
if grep -q 'E_sqrtC6eff' neutral.fluidDebug; then echo "1 1 0 Neutral CANON debug E_sqrtC6eff"; else echo "0 1 0 Neutral CANON debug E_sqrtC6eff"; fi

# Screened CANON tests
awk '/bulk screening length:/ { found = 1 } END { print (found ? 1 : 0), "1 0 Screened CANON screening log" }' screened.out
awk '/IonicMinimize: Iter/ { E = $5 } END { print E, "-24.42 0.05 Screened CANON energy [Eh]" }' screened.out
if grep -q 'E_Zcenter' screened.fluidDebug; then echo "1 1 0 Screened CANON debug E_Zcenter"; else echo "0 1 0 Screened CANON debug E_Zcenter"; fi
if grep -q 'E_Res' screened.fluidDebug; then echo "1 1 0 Screened CANON debug E_Res"; else echo "0 1 0 Screened CANON debug E_Res"; fi
if [ -f screened.fluidRhoIon ]; then echo "1 1 0 Screened CANON ionic bound charge dump"; else echo "0 1 0 Screened CANON ionic bound charge dump"; fi

# CANON parameter initialization check (sigmaVdw must be nonzero)
awk '/Nonlocal vdW cavity.*sigma =/ { split($0, a, "sigma = "); gsub(/ .*/, "", a[2]); print (a[2]+0 > 0.1 ? 1 : 0), "1 0 CANON sigmaVdw initialized" }' neutral.out
