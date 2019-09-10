#!/bin/bash

#tar czf test.tar.gz main.js package.json yarn.lock public LICENCE
#scp test.tar.gz 1.2.3.4:~
#rm test.tar.gz


ssh 1.2.3.4 << 'ENDSSH'
	pm2 stop test
	rm -rf test
	mkdir test
	tar xzf test.tar.gz -C test
	rm test.tar.gz
	cd test
	yarn istall
	pm2 start test
ENDSSH
