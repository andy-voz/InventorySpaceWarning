#!/bin/bash
cd res/
convert -format dds -define dds:compression=dxt5 -compose copyopacity sack-icon.png sack-icon.dds
cd -