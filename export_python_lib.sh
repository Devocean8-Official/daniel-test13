#!/bin/bash
echo "transferring lib files from docker to host ... $(date)"
cd $($HOME/.local/bin/poetry env info -p)/lib/python3.9/; zip -r /tmp/lib.zip ./site-packages   > /dev/null
cp /tmp/lib.zip /src/lib.zip
echo "file transfer completed. $(date)"