#!/bin/bash
# SC-perf-test.sh - Test performance of a file
# server.
#
# See small_usage() below for details
#
# Note. iperf3 v3.11 or later client is recommended as
# earlier versions may not work properly with the "-R" option.

# Defaults
DEFAULT_SIZE=1073741824
DEFAULT_REPS=10

SIZE=${SIZE-$DEFAULT_SIZE}
REPS=${REPS-$DEFAULT_REPS}

# File name used for tests
TEMP_FILE=DELETE-ME-SC-perf-test.bin

small_usage()
{
    echo "Usage: $0 <IP-address/hostname> <mount-point>"
    echo ""
    echo "<IP-address/hostname> : The IP address or hostname"
    echo "of the file server under test."
    echo
    echo "<mount-point> : The directory where the file server"
    echo "has been mounted. This is where files will be copied"
    echo "from and to. See the comments within the script for"
    echo "examples of mounting commands."
    echo ""
    echo "Make sure that the server is running 'iperf3 -s' and that"
    echo "the server has been mounted in the specified directory."
    echo ""
    echo "Environment Variables :"
    echo "SIZE : Change the default transfer bytes ($SIZE)"
    echo "REPS : Change the default number of repetitions per test ($REPS)."
}

# Examples for mounting samba shares.
#
# Mounting is normally done as the root user. First create
# a directory where the file server can be mounted. e.g.
#
# mkdir /tmp/NASX
#
# For normal samba server 192.0.2.99 you could use the following
# to mount the "Public" directory. "berto" is the name of the user
# performing the tests.
#
#    mount.cifs //192.0.2.99/Public /tmp/NASX -o username=guest,password=guest,uid=berto,gid=users
#
# To mount the "admin" user's directory you could use
#
#    mount.cifs //192.0.2.99/admin /tmp/NASX -o username=admin,password=myadminpassword,uid=berto,gid=users
#
# If you are testing a server running an old version of Samba
# that uses SMBv1.0 then you may need to mount using the vers=1.0
# parameter as follows.
#
#    mount.cifs //192.0.2.99/Public /tmp/NASX -o username=guest,password=guest,uid=berto,gid=users,vers=1.0
# 

IP_ADDR=$1
DIR=$2

check_params()
{
    if [[ -z $IP_ADDR ]]; then
	echo -e "Error : You must specify an IP address or hostname for the server to be tested"
	echo ""
	small_usage
	exit 1
    fi

    if [[ -z $DIR ]]; then
	echo -e "Error : You must specify the directory where the server file system is mounted"
	echo ""
	small_usage
	exit 1
    fi
}

check_iperf()
{
    RESULT=$(iperf3 -c $IP_ADDR --connect-timeout 3000 -n 2000 -i 0)
    IPERF_TEST=$?
    if [[ $IPERF_TEST -ne 0 ]]; then
	echo -e "Error connecting to iperf3 server on $IP_ADDR"
	return 1
    fi
}

check_file_transfer()
{
    echo "testing123" > $TEMP_FILE
    RESULT=$(cp -f $TEMP_FILE $DIR)
    CP_TO_TARGET_TEST=$?
    if [[ $CP_TO_TARGET_TEST -ne 0 ]]; then
	echo -e "Unable to copy file from local to target directory $DIR"
	return 1
    fi

    rm -f $TEMP_FILE
    RESULT=$(cp $DIR/$TEMP_FILE .)
    CP_FROM_TARGET_TEST=$?
    if [[ $CP_FROM_TARGET_TEST -ne 0 ]]; then
	echo -e "Unable to copy file from target directory $DIR to local"
	return 2
    fi
    rm -f $DIR/$TEMP_FILE
}


test_upload()
{
    echo ""
    echo "File copy upload speeds in KiBytes/sec from client to server mounted at $DIR"
    for ((i = 1 ; i <= $REPS ; i++)); do

	# We use dd if=/dev/zero rather than copying a
	# local file on disk to reduce reliance on
	# the client's disk peformance. Note also that we
	# change the filename for each test
	# to eliminate the possibility of any kind of
	# intelligent caching on the server. 
	RESULT=$(/usr/bin/time -o /dev/stdout -f %e dd if=/dev/zero of=$DIR/$TEMP_FILE-$i bs=$SIZE count=1 2>/dev/null)
	if [[ $? -ne 0 ]]; then
	    echo "Failed"
	else
	    echo "$SIZE / $RESULT / 1024" | bc
	fi

	rm $DIR/$TEMP_FILE-$i
	sleep 1
    done

}

test_download()
{

    echo ""

    # Create a file of the required size on the server.
    #
    if type fallocate > /dev/null ; then
    	# fallocate is much faster than dd but doesn't always work
    	fallocate -l $SIZE $DIR/$TEMP_FILE
	if [[ $? -ne 0 ]]; then
	    echo "fallocate failed. Trying dd"
	    echo ""
	    USE_DD=1
	fi
    else
	USE_DD=1
    fi

    if [[ USE_DD -eq 1 ]]; then
	dd if=/dev/zero of=$DIR/$TEMP_FILE bs=$SIZE count=1 2>/dev/null
	echo ""
    fi
    # ls -l $DIR/$TEMP_FILE    
    FILE_CREATE_RESULT=$?
    if [[ $FILE_CREATE_RESULT -ne 0 ]]; then
	echo -e "Unable to create $SIZE file for testing. Abandoning download test"
	return 1
    fi

    echo "File copy download speeds in KiBytes/sec from client to server mounted at $DIR"
    for ((i = 1 ; i <= $REPS ; i++)); do
	#
	# Change the name of the file being copied for each
	# test to make sure the file isn't cached either
	# on the server or the client. Could also use
	# vmtouch -e $DIR/$TEMP_FILE
	#
	mv $DIR/$TEMP_FILE $DIR/$TEMP_FILE-$i
	sleep 1

	# We copy the file to /dev/null rather than a normal
	# file on disk to reduce variability introduced due
	# to the client's disk performance.
	RESULT=$(/usr/bin/time -f %e cp $DIR/$TEMP_FILE-$i /dev/null 2>&1)
	if [[ $? -ne 0 ]]; then
	    echo "Failed"
	else
	    echo "$SIZE / $RESULT / 1024" | bc
	fi
	mv $DIR/$TEMP_FILE-$i $DIR/$TEMP_FILE
	sleep 1
    done
    rm $DIR/$TEMP_FILE
}

test_iperf_upload()
{
    echo ""
    echo "Raw TCP upload speeds in Kibits/s from client to server $IP_ADDR."

    for ((i = 1 ; i <= $REPS ; i++)); do
	iperf3 -fk -n$SIZE  -c $IP_ADDR | grep receiver | cut -b39-54 | cut -d' ' -f1
	if [[ $? -ne 0 ]]; then
	    echo "Failed"
	fi
	# The pause using "sleep" here significantly reduces the number of failed tests.
	sleep 1
    done
}

test_iperf_download()
{
    echo ""
    echo "Raw TCP download speeds in Kibits/s from server $IP_ADDR to client"
    for ((i = 1 ; i <= $REPS ; i++)); do
	iperf3 -fk -n$SIZE  -c $IP_ADDR -R | grep sender | cut -b39-54 | cut -d' ' -f1
	if [[ $? -ne 0 ]]; then
	    echo "Failed"
	fi
	sleep 1
    done
}

check_params
echo "Performing $REPS repetitions per test. Each test is $SIZE bytes."

# The default behavior is to check that each type of test
# will work and then if they *ALL* work then proceed
# with all the tests in order.
# You could re-arrange the functions and if statements
# below so that even if one type of test check failed,
# the other tests could proceed.

check_iperf
RESULT=$?
if [[ $RESULT -ne 0 ]]; then
    echo Exiting. iperf check failed
    exit 1
fi

check_file_transfer
RESULT=$?
if [[ $RESULT -ne 0 ]]; then
    echo Exiting. File Transfer check failed.
    exit 1
fi

# File transfer tests
test_upload
test_download

# Raw tcp throghput tests
test_iperf_upload
test_iperf_download

