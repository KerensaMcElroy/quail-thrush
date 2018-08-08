#!/bin/bash

module add lftp

cd /OSM/CBR/NRCA_FINCHGENOM/data/2015-10-01_quail

sftp -b ~/*thrush/data/files.txt -P 1046 mce03b@upload.data.csiro.au:/20800/33658v001/data/

cd /OSM/CBR/NRCA_FINCHGENOM/data/2015-11-12_libraries

sftp -b ~/*thrush/data/files.txt -P 1046 mce03b@upload.data.csiro.au:/20800/33658v001/data/


