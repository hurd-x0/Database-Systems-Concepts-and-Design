#################################################
## Author: David Ribeiro			#
## Date: 7/6/2018				#
## Purpose: Automate Application Setup		#
## Assumption: Using Ubuntu 16.04		#
##	1) Change to root (sudo) user		#
##	2) cd into the directory of this file	#
##	3) Run chmod a+rwx <file_name>		#
##	4) Run yes | ./<file_name>		#
##  5) If permissions denied, replace the root password in lines 25 to 28
##     --password= <password> and uncomment. Comment out lines 21 to 24. 
#################################################
cd $(dirname $0)
apt-get update
apt-get upgrade
apt-get install python3
apt-get install python3-pip
pip3 install Flask
pip3 install flask-mysql
apt-get install mariadb-server
mysql < database_setup.sql
mysql cs6400 < schema.sql
mysql cs6400 < stored_procedures.sql
mysql cs6400 < stage_data.sql
# mysql --user=root --password= <password> < database_setup.sql
# mysql --user=root --password= <password> < schema.sql
# mysql --user=root --password= <password> < stored_procedures.sql
# mysql --user=root --password= <password> < stage_data.sql
