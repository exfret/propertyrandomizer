#!/bin/bash
# Runs one seed headless on the overlay mod copy, with its own write-data dir
# Usage: MEASURE_DIR=<scratch dir holding mod/> ./run.sh <seed>
# Build mod/ first: python3 overlay.py <repo> $MEASURE_DIR/mod randomizations/graph/unified/skeleton/monotone-matching.lua
# then copy monotone-matching-measured.lua.txt over $MEASURE_DIR/mod/randomizations/graph/unified/skeleton/monotone-matching.lua
seed=$1
R=$MEASURE_DIR/seed-$seed
rm -rf $R && mkdir -p $R/mods $R/data
ln -s $MEASURE_DIR/mod $R/mods/propertyrandomizer
cp "/Users/kylehess/Library/Application Support/factorio/mods/propertyrandomizer/tests/mod-configs/sa.json" $R/mods/mod-list.json
python3 "/Users/kylehess/Library/Application Support/factorio/mods/propertyrandomizer/dev/mod-settings.py" set "/Users/kylehess/Library/Application Support/factorio/mods/propertyrandomizer/../mod-settings.dat" $R/mods/mod-settings.dat propertyrandomizer-seed=$seed >/dev/null
printf '[path]\nread-data=__PATH__executable__/../data\nwrite-data=%s\n' $R/data > $R/config.ini
/Applications/factorio.app/Contents/MacOS/factorio -c $R/config.ini --mod-directory $R/mods --create $R/save.zip > $R/factorio.log 2>&1
echo "seed $seed exit $?"
