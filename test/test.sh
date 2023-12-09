#!/bin/bash

# prepare test set
cp -r TestSet/ working-test-set/

# run obsidian-link-converter
../olc.sh working-test-set/ >> /dev/null

# compare results
while IFS= read -r line1 && IFS= read -r line2 <&3; do
    if [[ ${line2:0:5} == "#### " ]]; then
    	echo ""
    	echo ">> TEST: ${line1:5} >>>>>>>>>>>>>"
    	continue
    fi
    if [ "$line1" != "$line2" ]; then
        echo "Test failed"
        echo "  expected: $line2"
        echo "  got:      $line1"
    else
    	echo "Test succeeded"
    fi
done < "./working-test-set/subfolder 1/linktest.md" 3< "expect.md"

# reset test set
rm -rf working-test-set/

