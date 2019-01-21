#################################################
## Author: Chang-Zhou Gong			#
## Date: 1/2/2019				#
## Purpose: Automate Application Setup		#
## Assumption: Using Mac		#
##	1) Change to root (sudo) user		#
##	2) cd into the directory of this file	#
##	3) Run chmod a+rwx <file_name>		#
##	4) Run yes | ./<file_name>		#
##  5) If permissions denied, replace the root password in lines 25 to 28
##     --password= <password> and uncomment. Comment out lines 21 to 24. 
##
#################################################
cd $(dirname $0)
brew update
brew upgrade
brew install python3
pip install Flask
pip install flask-mysql
brew install mariadb
mysql < database_setup.sql
mysql cs6400 < schema.sql
mysql cs6400 < stored_procedures.sql
mysql cs6400 < stage_data.sql
# mysql --user=root --password= < database_setup.sql
# mysql --user=root --password= < schema.sql
# mysql --user=root --password= < stored_procedures.sql
# mysql --user=root --password= < stage_data.sql
