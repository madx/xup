#!/bin/bash
rm -rf doc && rdoc -S -f html -N -m README.rdoc lib/ README.rdoc
