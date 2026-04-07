#!/bin/bash
#Combined checkpoint test: dump State, OMP_NUM_THREADS, and SIGQUIT emergency dump.
#Uses custom runner (runs="") since SIGQUIT test needs background process control.
export runs=""
export nProcs="1"

unset SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=3

testSrcDir="$SRCDIR"
JDFTX="$4/jdftx$JDFTX_SUFFIX"
if [ ! -x "$JDFTX" ]; then
    JDFTX="$(dirname "$(dirname "$(pwd)")")/jdftx$JDFTX_SUFFIX"
fi

#Run 1: Standard run with dump End State (also verifies OMP_NUM_THREADS)
echo "=== Run: withStateDump (OMP_NUM_THREADS=$OMP_NUM_THREADS) ==="
$JDFTX -i "$testSrcDir/withStateDump.in" -d -o withStateDump.out

#Run 2: Emergency checkpoint via SIGQUIT
echo "=== Run: emergency SIGQUIT test ==="
rm -f emergency.*
$JDFTX -i "$testSrcDir/emergency.in" -d -o emergency.out &
JDFTX_PID=$!
echo "Started jdftx PID=$JDFTX_PID"

while kill -0 "$JDFTX_PID" 2>/dev/null; do
    if grep -q "ElecMinimize: Iter:" emergency.out 2>/dev/null; then
        echo "Sending SIGQUIT ..."
        kill -QUIT $JDFTX_PID 2>/dev/null
        break
    fi
    sleep 0.01
done

wait $JDFTX_PID 2>/dev/null
echo "jdftx exited with code $?"

#Run 3: LCAO dump-interval (tests non-destructive GPU write during LCAO)
echo "=== Run: lcaoDump (dump-interval Electronic during LCAO) ==="
rm -f lcaoDump.*
$JDFTX -i "$testSrcDir/lcaoDump.in" -d -o lcaoDump.out

#Run 4: Restart from LCAO-phase wfns (tests that dumped wfns are usable)
echo "=== Run: lcaoDumpRestart (restart from LCAO wfns) ==="
rm -f lcaoDumpRestart.*
$JDFTX -i "$testSrcDir/lcaoDumpRestart.in" -d -o lcaoDumpRestart.out
