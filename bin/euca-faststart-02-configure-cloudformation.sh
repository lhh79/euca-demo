#/bin/bash
#
# This script configures Eucalyptus CloudFormation after a Faststart installation
#
# This should be run after the Faststart installer completes, and the DNS
# configuration script has also been run.
#

#  1. Initalize Environment

if [ -z $EUCA_VNET_MODE ]; then
    echo "Please set environment variables first"
    exit 3
fi

[ "$(hostname -s)" = "$EUCA_CLC_HOST_NAME" ] && is_clc=y || is_clc=n

bindir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
confdir=${bindir%/*}/conf
docdir=${bindir%/*}/doc
logdir=${bindir%/*}/log
scriptsdir=${bindir%/*}/scripts
templatesdir=${bindir%/*}/templates
tmpdir=/var/tmp

step=0
speed_max=400
run_default=10
pause_default=2
next_default=5

interactive=1
speed=100


#  2. Define functions

usage () {
    echo "Usage: ${BASH_SOURCE##*/} [-I [-s | -f]]"
    echo "  -I  non-interactive"
    echo "  -s  slower: increase pauses by 25%"
    echo "  -f  faster: reduce pauses by 25%"
}

run() {
    if [ -z $1 ] || (($1 % 25 != 0)); then
        ((seconds=run_default * speed / 100))
    else
        ((seconds=run_default * $1 * speed / 10000))
    fi
    if [ $interactive = 1 ]; then
        echo
        echo -n "Run? [Y/n/q]"
        read choice
        case "$choice" in
            "" | "y" | "Y" | "yes" | "Yes") choice=y ;;
            "n" | "N" | "no" | "No") choice=n ;;
             *) echo "cancelled"
                exit 2;;
        esac
    else
        echo
        echo -n -e "Waiting $(printf '%2d' $seconds) seconds..."
        while ((seconds > 0)); do
            if ((seconds < 10 || seconds % 10 == 0)); then
                echo -n -e "\rWaiting $(printf '%2d' $seconds) seconds..."
            fi
            sleep 1
            ((seconds--))
        done
        echo " Done"
        choice=y
    fi
}

pause() {
    if [ -z $1 ] || (($1 % 25 != 0)); then
        ((seconds=pause_default * speed / 100))
    else
        ((seconds=pause_default * $1 * speed / 10000))
    fi
    if [ $interactive = 1 ]; then
        echo "#"
        read pause
        echo -en "\033[1A\033[2K"    # undo newline from read
    else
        echo "#"
        sleep $seconds
    fi
}

next() {
    if [ -z $1 ] || (($1 % 25 != 0)); then
        ((seconds=next_default * speed / 100))
    else
        ((seconds=next_default * $1 * speed / 10000))
    fi
    if [ $interactive = 1 ]; then
        echo
        echo -n "Next? [Y/q]"
        read choice
        case "$choice" in
            "" | "y" | "Y" | "yes" | "Yes") choice=y ;;
             *) echo "cancelled"
                exit 2;;
        esac
    else
        echo
        echo -n -e "Waiting $(printf '%2d' $seconds) seconds..."
        while ((seconds > 0)); do
            if ((seconds < 10 || seconds % 10 == 0)); then
                echo -n -e "\rWaiting $(printf '%2d' $seconds) seconds..."
            fi
            sleep 1
            ((seconds--))
        done
        echo " Done"
        choice=y
    fi
}


#  3. Parse command line options

while getopts Isf? arg; do
    case $arg in
    I)  interactive=0;;
    s)  ((speed < speed_max)) && ((speed=speed+25));;
    f)  ((speed > 0)) && ((speed=speed-25));;
    ?)  usage
        exit 1;;
    esac
done

shift $(($OPTIND - 1))


#  4. Validate environment

if [ $is_clc = n ]; then
    echo "This script should only be run on the Cloud Controller host"
    exit 10
fi

if [ ! -r /root/creds/eucalyptus/admin/eucarc ]; then
    echo "Could not find Eucalyptus Administrator credentials!"
    echo "Expected to find: /root/creds/eucalyptus/admin/eucarc"
    sleep 2

    if [ -r /root/admin.zip ]; then
        echo "Moving Faststart Eucalyptus Administrator credentials to appropriate creds directory"
        mkdir -p /root/creds/eucalyptus/admin
        unzip /root/admin.zip -d /root/creds/eucalyptus/admin/
        sed -i -e '/EUCALYPTUS_CERT=/aexport EC2_CERT=${EUCA_KEY_DIR}/cloud-cert.pem' /root/creds/eucalyptus/admin/eucarc    # invisibly fix missing property still needed for image import
        sleep 2
    else
        echo "Could not convert FastStart Eucalyptus Administrator credentials!"
        echo "Expected to find: /root/admin.zip"
        exit 29
    fi
fi


#  5. Execute Demo

start=$(date +%s)

((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Use Eucalyptus Administrator credentials"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "cat /root/creds/eucalyptus/admin/eucarc"
echo
echo "source /root/creds/eucalyptus/admin/eucarc"

next

echo
echo "# cat /root/creds/eucalyptus/admin/eucarc"
cat /root/creds/eucalyptus/admin/eucarc
pause

echo "# source /root/creds/eucalyptus/admin/eucarc"
source /root/creds/eucalyptus/admin/eucarc

next


((++step))
if euca-describe-services | grep -s -q "^SERVICE.cloudformation"; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Register CloudFormation service"
    echo "    - Already Installed!"
    echo
    echo "============================================================"

    next 50

else
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Register CloudFormation service"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "euca_conf --register-service -T CloudFormation -H $EUCA_UFS_PUBLIC_IP -N cfn"

    run 50

    if [ $choice = y ]; then
        echo
        echo "# euca_conf --register-service -T CloudFormation -H $EUCA_UFS_PUBLIC_IP -N cfn"
        euca_conf --register-service -T CloudFormation -H $EUCA_UFS_PUBLIC_IP -N cfn

        next 50
    fi
fi


((++step))
if grep -s -q "AWS_CLOUDFORMATION_URL=" /root/creds/eucalyptus/admin/eucarc; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Refresh Administrator Credentials"
    echo "    - Unnecessary! Credentials contain Cloudformation URL"
    echo
    echo "============================================================"

    next 50

else
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Refresh Administrator Credentials"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "rm -f /root/admin.zip"
    echo
    echo "euca-get-credentials -u admin /root/admin.zip"
    echo
    echo "rm -Rf /root/creds/eucalyptus/admin"
    echo "mkdir -p /root/creds/eucalyptus/admin"
    echo "unzip /root/admin.zip -d /root/creds/eucalyptus/admin/"
    echo
    echo "cat /root/creds/eucalyptus/admin/eucarc"
    echo
    echo "source /root/creds/eucalyptus/admin/eucarc"

    run 50

    if [ $choice = y ]; then
        echo
        echo "# rm -f /root/admin.zip"
        rm -f /root/admin.zip
        pause

        echo "# euca-get-credentials -u admin /root/admin.zip"
        euca-get-credentials -u admin /root/admin.zip
        pause

        # Save and restore the admin-demo.pem if it exists (should not yet)
        [ -r /root/creds/eucalyptus/admin/admin-demo.pem ] && cp -a /root/creds/eucalyptus/admin/admin-demo.pem /tmp/admin-demo.pem_$$
        echo "# rm -Rf /root/creds/eucalyptus/admin"
        rm -Rf /root/creds/eucalyptus/admin
        echo "#"
        echo "# mkdir -p /root/creds/eucalyptus/admin"
        mkdir -p /root/creds/eucalyptus/admin
        [ -r /tmp/admin-demo.pem_$$ ] && cp -a /tmp/admin-demo.pem_$$ /root/creds/eucalyptus/admin/admin-demo.pem; rm -f /tmp/admin-demo.pem_$$
        echo "#"
        echo "# unzip /root/admin.zip -d /root/creds/eucalyptus/admin/"
        unzip /root/admin.zip -d /root/creds/eucalyptus/admin/
        sed -i -e '/EUCALYPTUS_CERT=/aexport EC2_CERT=${EUCA_KEY_DIR}/cloud-cert.pem' /root/creds/eucalyptus/admin/eucarc    # invisibly fix missing property still needed for image import
        if [ -r /root/eucarc ]; then
            cp /root/creds/eucalyptus/admin/eucarc /root/eucarc    # invisibly update Faststart credentials location
        fi
        pause

        echo "# cat /root/creds/eucalyptus/admin/eucarc"
        cat /root/creds/eucalyptus/admin/eucarc
        pause

        echo "# source /root/creds/eucalyptus/admin/eucarc"
        source /root/creds/eucalyptus/admin/eucarc

        next 50
    fi
fi


((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Confirm service status"
echo "    - You should now see the CloudFormation Service"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "euca-describe-services | cut -f1-5"

run 50

if [ $choice = y ]; then
    echo
    echo "# euca-describe-services | cut -f1-5"
    euca-describe-services | cut -f1-5

    next
fi


((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Verify CloudFormation service"
echo "    - Upon installation, there should be no output (no errors)"
echo "    - If run after installation, you may see existing Stacks"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "euform-describe-stacks"

run 50

if [ $choice = y ]; then
    echo
    echo "# euform-describe-stacks"
    euform-describe-stacks

    next 50
fi


end=$(date +%s)

echo
echo "Eucalyptus CloudFormation configuration complete (time: $(date -u -d @$((end-start)) +"%T"))"
