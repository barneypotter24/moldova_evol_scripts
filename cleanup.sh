#!/bin/bash

removeforMSA="/vast/palmer/pi/cohen_theodore/M_tuberculosis/moldova/moldova_evol/private_metadata/RemoveFromMSAPipeline.csv"
cut -d',' -f3 $removeforMSA | tail -n +2 | tr -d '"'> remove_ids.list


if[[-f 
