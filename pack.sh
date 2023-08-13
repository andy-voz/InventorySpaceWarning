#!/bin/bash
rm -rf .pack

mkdir -p .pack/InventorySpaceWarning

rsync -a InventorySpaceWarning.txt .pack/InventorySpaceWarning/
rsync -a src .pack/InventorySpaceWarning/
rsync -a ui .pack/InventorySpaceWarning/
rsync -a res/*.dds .pack/InventorySpaceWarning/res/

cd .pack
zip -r InventorySpaceWarning.zip InventorySpaceWarning
cd -
