#!/bin/bash

# SC-perf-test.sh <ip-address> <mount-point>

# File size for transfer tests 1GiB (1073741824 bytes)

DEFAULT_SIZE=1073741824
DEFAULT_REPS=10

SIZE=${SIZE-$DEFAULT_SIZE}

# File name used for tests
TEMP_FILE=DELETE-ME-SC-perf-test.bin

# Number of times to repeat each test
REPS=${REPS-$DEFAULT_REPS}

small_usage()
{
    echo "Usage: $0 <IP-address/hostname> <mount-point>"
    echo ""
    echo "<IP-address/hostname> : The IP address or hostname"
    echo "of the file server under test."
    echo
    echo "<mount-point> : The directory where the file server"
    echo "has been mounted. This is where files will be copied"
    echo "from and to."
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
# For normal samba server 192.0.2.99 you could use the following
# to mount the "Public" directory.
#
#    mount.cifs //192.0.2.99/Public /mnt/NASX -o username=guest,password=guest,uid=berto,gid=users
#
# To mount the "admin" user's directory you could use
#
#    mount.cifs //192.0.2.99/admin /mnt/NASX -o username=admin,password=myadminpassword,uid=berto,gid=users
#
# If you are testing a server running an old version of Samba
# that uses SMBv1.0 then you may need to mount using the vers=1.0
# parameter as follows.
#
#    mount.cifs //192.0.2.99/Public /mnt/NASX -o username=guest,password=guest,uid=berto,gid=users,vers=1.0
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
	echo -e "See the $0 script for examples of how to mount an smb file system."
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
    # Create a file of the required size
    if type fallocate > /dev/null ; then
	# fallocate is much faster than dd
	fallocate -l $SIZE $TEMP_FILE
    else
	dd if=/dev/random of=$TEMP_FILE bs=$SIZE count=1
    fi
    FILE_CREATE_RESULT=$?
    if [[ $FILE_CREATE_RESULT -ne 0 ]]; then
	echo -e "Unable to create $SIZE file for testing. Abandoning upload test"
	return 1
    fi

    echo ""
    echo "File copy upload speeds in KiBytes/sec from client to server mounted at $DIR"
    for ((i = 1 ; i <= $REPS ; i++)); do
	RESULT=$(/usr/bin/time -f %e cp $TEMP_FILE $DIR 2>&1)
	if [[ $? -ne 0 ]]; then
	    echo "Failed"
	else
	    echo "$SIZE / $RESULT / 1024" | bc
	fi
	rm $DIR/$TEMP_FILE
	sleep 1
    done

    rm -f $TEMP_FILE
}

test_download()
{

    # Create a file of the required size. We do this here
    # to make sure that the local machine can actually
    # store a file of the size that we're downloading.
    #
    if type fallocate > /dev/null ; then
	# fallocate is much faster than dd
	fallocate -l $SIZE $TEMP_FILE
    else
	dd if=/dev/random of=$TEMP_FILE bs=$SIZE count=1
    fi
    FILE_CREATE_RESULT=$?
    if [[ $FILE_CREATE_RESULT -ne 0 ]]; then
	echo -e "Unable to create $SIZE file for testing. Abandoning download test"
	return 1
    fi

    # Transfer the file to the server so it can then be downloaded
    mv $TEMP_FILE $DIR
    sleep 1
    
    echo ""
    echo "File copy download speeds in KiBytes/sec from client to server mounted at $DIR"
    for ((i = 1 ; i <= $REPS ; i++)); do
	RESULT=$(/usr/bin/time -f %e cp $DIR/$TEMP_FILE . 2>&1)
	if [[ $? -ne 0 ]]; then
	    echo "Failed"
	else
	    echo "$SIZE / $RESULT / 1024" | bc
	fi
	rm $TEMP_FILE
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

test_upload
test_download
test_iperf_upload
test_iperf_download

