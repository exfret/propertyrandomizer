start=$(perl -MTime::HiRes=time -e 'print time')

MOD_DIR="/Users/kylehess/Library/Application Support/factorio/mods-randomizer-testing"

for file1 in ./tests/mod-configs/*; do
    printf "Using modset $(basename "$file1")\n"
    cp -- "$file1" "$MOD_DIR/mod-list.json"
    for file2 in ./tests/settings-configs/*; do
        [ -e "$file2" ] || continue   # handles empty directories (no matches)
        echo "Conducting test $(basename "$file2")"
        cp -- "$file2" "$MOD_DIR/mod-settings.dat"
        FACTORIO_EXIT=0
        /Applications/factorio.app/Contents/MacOS/factorio \
            --mod-directory "$MOD_DIR" \
            --create "./tests/test-save.zip" \
            > "./tests/current.log" 2>&1 || FACTORIO_EXIT=$?
        if [ $FACTORIO_EXIT -ne 0 ]; then
            echo "TEST FAILED (Did you exit Factorio first?)"
            exit 1
        fi
    done
done

end=$(perl -MTime::HiRes=time -e 'print time')
elapsed=$(perl -e "printf('%.2f', $end - $start)")
echo "ALL TESTS PASSED in ${elapsed}s!"