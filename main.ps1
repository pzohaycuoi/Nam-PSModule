######################################################################################################################
# PREREQUISITE #
######################################################################################################################

# Create log file #
#------------------------------------------------------------------------#
# All prerequisite information will go into this log file

# Check version of powershell #
#------------------------------------------------------------------------#
# Require powershell core 6.0 or above

# Check existance of required powershell module #
#------------------------------------------------------------------------#
# Required powershell module:
# 1. AD module
# 2. Msol module
# 3. Exchange module

# If module not exist then install #
#------------------------------------------------------------------------#
# Set trusted repository - so powershell won't ask for confirmation
# Installation

# Check again if installation success or not - if not then throw #
#------------------------------------------------------------------------#

######################################################################################################################
# CREATE AD USER #
######################################################################################################################

# Import list of user from CSV file #
#------------------------------------------------------------------------#

# Check if any user on the list is exist yet #
#------------------------------------------------------------------------#
# If exist append to log file and export existed user to csv file

# Create users aren't exist #
#------------------------------------------------------------------------#
# Implement try catch and sleep to reduce error caused by time out
# Need a csv file or hash table for destination OU and namving convention of sec group
