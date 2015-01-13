#/bin/bash
#
# This script configures Eucalyptus networking
#
# Each student MUST run all prior scripts on all nodes prior to this script.
#

#  1. Initalize Environment

bindir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
confdir=${bindir%/*}/conf
docdir=${bindir%/*}/doc
logdir=${bindir%/*}/log
scriptsdir=${bindir%/*}/scripts
templatesdir=${bindir%/*}/templates
tmpdir=/var/tmp

step=0
interactive=1

is_clc=n
is_ufs=n
is_mc=n
is_cc=n
is_sc=n
is_osp=n
is_nc=n


#  2. Define functions

usage () {
    echo "Usage: $(basename $0) [-I]"
    echo "  -I non-interactive"
}

pause() {
    if [ "$interactive" = 1 ]; then
        read pause
    else
        sleep 5
    fi
}

choose() {
    if [ "$interactive" = 1 ]; then
        [ -n "$1" ] && prompt2="$1 (y,n,q)[y]"
        [ -z "$1" ] && prompt2="Proceed[y]?"
        echo
        echo -n "$prompt2"
        read choice
        case "$choice" in
            "" | "y" | "Y" | "yes" | "Yes") choice=y ;;
            "n" | "N" | "no" | "No") choice=n ;;
             *) echo "cancelled"
                exit 2;;
        esac
    else
        sleep 5
        choice=y
    fi
}


#  3. Parse command line options

while getopts I arg; do
    case $arg in
    I)  interactive=0;;
    ?)  usage
        exit 1;;
    esac
done

shift $(($OPTIND - 1))


#  4. Validate environment

if [ -z $EUCA_VNET_MODE ]; then
    echo
    echo "Please set environment variables first"
    exit 1
fi

[ "$(hostname -s)" = "$EUCA_CLC_HOST_NAME" ] && is_clc=y
[ "$(hostname -s)" = "$EUCA_UFS_HOST_NAME" ] && is_ufs=y
[ "$(hostname -s)" = "$EUCA_MC_HOST_NAME" ] && is_mc=y
[ "$(hostname -s)" = "$EUCA_CC_HOST_NAME" ] && is_cc=y
[ "$(hostname -s)" = "$EUCA_SC_HOST_NAME" ] && is_sc=y
[ "$(hostname -s)" = "$EUCA_OSP_HOST_NAME" ] && is_osp=y
[ "$(hostname -s)" = "$EUCA_NC1_HOST_NAME" ] && is_nc=y
[ "$(hostname -s)" = "$EUCA_NC2_HOST_NAME" ] && is_nc=y
[ "$(hostname -s)" = "$EUCA_NC3_HOST_NAME" ] && is_nc=y
[ "$(hostname -s)" = "$EUCA_NC4_HOST_NAME" ] && is_nc=y
 

#  5. Execute Course Lab

((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Configure Eucalyptus Networking"
echo "    - We'll save the original file first"
echo "    - Then we'll use sed to quickly change parameters"
echo "    - Then we'll diff the modified and original files to show changes"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "cp -a /etc/eucalyptus/eucalyptus.conf /etc/eucalyptus/eucalyptus.conf.orig"
echo
echo "sed -i -e \"s/^VNET_MODE=.*$/VNET_MODE=\\\"$EUCA_VNET_MODE\\\"/\" \\"
echo "       -e \"s/^VNET_PRIVINTERFACE=.*$/VNET_PRIVINTERFACE=\\\"$EUCA_VNET_PRIVINTERFACE\\\"/\" \\"
echo "       -e \"s/^VNET_PUBINTERFACE=.*$/VNET_PUBINTERFACE=\\\"$EUCA_VNET_PUBINTERFACE\\\"/\" \\"
echo "       -e \"s/^VNET_BRIDGE=.*$/VNET_BRIDGE=\\\"$EUCA_VNET_BRIDGE\\\"/\" \\"
echo "       -e \"s/^#VNET_PUBLICIPS=.*$/VNET_PUBLICIPS=\\\"$EUCA_VNET_PUBLICIPS\\\"/\" \\"
echo "       -e \"s/^#VNET_SUBNET=.*$/VNET_SUBNET=\\\"$EUCA_VNET_SUBNET\\\"/\" \\"
echo "       -e \"s/^#VNET_NETMASK=.*$/VNET_NETMASK=\\\"$EUCA_VNET_NETMASK\\\"/\" \\"
echo "       -e \"s/^#VNET_ADDRSPERNET=.*$/VNET_ADDRSPERNET=\\\"$EUCA_VNET_ADDRSPERNET\\\"/\" \\"
echo "       -e \"s/^#VNET_DNS.*$/VNET_DNS=\\\"$EUCA_VNET_DNS\\\"/\" /etc/eucalyptus/eucalyptus.conf"
echo
echo "diff /etc/eucalyptus/eucalyptus.conf{,.orig}"

choose "Execute"
             
if [ $choice = y ]; then
    echo
    echo "# cp -a /etc/eucalyptus/eucalyptus.conf /etc/eucalyptus/eucalyptus.conf.orig"
    cp -a /etc/eucalyptus/eucalyptus.conf /etc/eucalyptus/eucalyptus.conf.orig
    pause

    echo "# sed -i -e \"s/^VNET_MODE=.*$/VNET_MODE=\\\"$EUCA_VNET_MODE\\\"/\" \\"
    echo ">        -e \"s/^VNET_PRIVINTERFACE=.*$/VNET_PRIVINTERFACE=\\\"$EUCA_VNET_PRIVINTERFACE\\\"/\" \\"
    echo ">        -e \"s/^VNET_PUBINTERFACE=.*$/VNET_PUBINTERFACE=\\\"$EUCA_VNET_PUBINTERFACE\\\"/\" \\"
    echo ">        -e \"s/^VNET_BRIDGE=.*$/VNET_BRIDGE=\\\"$EUCA_VNET_BRIDGE\\\"/\" \\"
    echo ">        -e \"s/^#VNET_PUBLICIPS=.*$/VNET_PUBLICIPS=\\\"$EUCA_VNET_PUBLICIPS\\\"/\" \\"
    echo ">        -e \"s/^#VNET_SUBNET=.*$/VNET_SUBNET=\\\"$EUCA_VNET_SUBNET\\\"/\" \\"
    echo ">        -e \"s/^#VNET_NETMASK=.*$/VNET_NETMASK=\\\"$EUCA_VNET_NETMASK\\\"/\" \\"
    echo ">        -e \"s/^#VNET_ADDRSPERNET=.*$/VNET_ADDRSPERNET=\\\"$EUCA_VNET_ADDRSPERNET\\\"/\" \\"
    echo ">        -e \"s/^#VNET_DNS.*$/VNET_DNS=\\\"$EUCA_VNET_DNS\\\"/\" /etc/eucalyptus/eucalyptus.conf"
    sed -i -e "s/^VNET_MODE=.*$/VNET_MODE=\"$EUCA_VNET_MODE\"/" \
           -e "s/^VNET_PRIVINTERFACE=.*$/VNET_PRIVINTERFACE=\"$EUCA_VNET_PRIVINTERFACE\"/" \
           -e "s/^VNET_PUBINTERFACE=.*$/VNET_PUBINTERFACE=\"$EUCA_VNET_PUBINTERFACE\"/" \
           -e "s/^VNET_BRIDGE=.*$/VNET_BRIDGE=\"$EUCA_VNET_BRIDGE\"/" \
           -e "s/^#VNET_PUBLICIPS=.*$/VNET_PUBLICIPS=\"$EUCA_VNET_PUBLICIPS\"/" \
           -e "s/^#VNET_SUBNET=.*$/VNET_SUBNET=\"$EUCA_VNET_SUBNET\"/" \
           -e "s/^#VNET_NETMASK=.*$/VNET_NETMASK=\"$EUCA_VNET_NETMASK\"/" \
           -e "s/^#VNET_ADDRSPERNET=.*$/VNET_ADDRSPERNET=\"$EUCA_VNET_ADDRSPERNET\"/" \
           -e "s/^#VNET_DNS.*$/VNET_DNS=\"$EUCA_VNET_DNS\"/" /etc/eucalyptus/eucalyptus.conf
    pause

    echo "# diff /etc/eucalyptus/eucalyptus.conf{,.orig}"
    diff /etc/eucalyptus/eucalyptus.conf{,.orig}

    choose "Continue"
fi


if [ $is_cc = y ]; then
    ((++step))
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Restart the Cluster Controller service"
    echo "    - This step is only run on the Cluster Controller host"
    echo "    - Note you need to run the next step on all Node Controllers, before continuing"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "service eucalyptus-cc restart"

    choose "Execute"

    if [ $choice = y ]; then
        echo
        echo "# service eucalyptus-cc restart"
        service eucalyptus-cc restart

        choose "Continue"
    fi
fi


if [ $is_nc = y ]; then
    ((++step))
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Restart the Node Controller service"
    echo "    - This step is only run on Node Controller hosts"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "service eucalyptus-nc restart"

    choose "Execute"

    if [ $choice = y ]; then
        echo
        echo "# service eucalyptus-nc restart"
        service eucalyptus-nc restart

        choose "Continue"
    fi
fi


if [ $is_clc = y ]; then
    ((++step))
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Initialize Administrator Credentials"
    echo "    - This step is only run on the Cloud Controller host"
    echo "    - You should have restarted all Node Controllers prior to this step"
    echo "    - Expect the OSG not configured warning"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "euca_conf --get-credentials /root/admin.zip"
    echo
    echo "mkdir -p /root/creds/eucalyptus/admin"
    echo "unzip /root/admin.zip -d /root/creds/eucalyptus/admin/"
    echo
    echo "source /root/creds/eucalyptus/admin/eucarc"

    choose "Execute"

    if [ $choice = y ]; then
        echo
        echo "# euca_conf --get-credentials /root/admin.zip"
        euca_conf --get-credentials /root/admin.zip
        pause

        echo "# mkdir -p /root/creds/eucalyptus/admin"
        mkdir -p /root/creds/eucalyptus/admin
        echo "# unzip /root/admin.zip -d /root/creds/eucalyptus/admin/"
        unzip /root/admin.zip -d /root/creds/eucalyptus/admin/
        sed -i -e 's/EUARE_URL=/AWS_IAM_URL=/' /root/creds/eucalyptus/admin/eucarc    # invisibly fix deprecation message
        pause

        echo "# source /root/creds/eucalyptus/admin/eucarc"
        source /root/creds/eucalyptus/admin/eucarc

        choose "Continue"
    fi
fi


if [ $is_clc = y ]; then
    ((++step))
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Confirm Public IP addresses"
    echo "    - This step is only run on the Cloud Controller host"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "euca-describe-addresses verbose"

    choose "Execute"

    if [ $choice = y ]; then
        echo
        echo "# euca-describe-addresses verbose"
        euca-describe-addresses verbose

        choose "Continue"
    fi
fi


if [ $is_clc = y ]; then
    ((++step))
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Confirm Instance Types"
    echo "    - This step is only run on the Cloud Controller host"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "euca-describe-instance-types --show-capacity"

    choose "Execute"

    if [ $choice = y ]; then
        echo
        echo "# euca-describe-instance-types --show-capacity"
        euca-describe-instance-types --show-capacity

        choose "Continue"
    fi
fi


echo
echo "Network configuration complete"