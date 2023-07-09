#!/bin/bash
rm -rf .pack
mkdir -p .pack/InventoryWarning
cp InventoryWarning.* .pack/InventoryWarning/
cp res/*.dds .pack/InventoryWarning/res/
cd .pack
zip -r InventoryWarning.zip InventoryWarning
cd -
