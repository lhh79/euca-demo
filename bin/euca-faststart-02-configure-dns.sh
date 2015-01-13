#!/bin/bash
#
# This script configures Eucalyptus DNS after a Faststart installation
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

if [ $(hostname -s) != $EUCA_CLC_HOST_NAME ]; then
    echo
    echo "This script should be run only on a Cloud Controller"
    exit 2
fi


#  5. Convert FastStart credentials to Course directory structure

if [ -r /root/creds/eucalyptus/admin/eucarc ]; then
    echo "Found Eucalyptus Administrator credentials"
elif [ -r /root/admin.zip ]; then
    echo "Moving Faststart Eucalyptus Administrator credentials to appropriate creds directory"
    mkdir -p /root/creds/eucalyptus/admin
    unzip /root/admin.zip -d /root/creds/eucalyptus/admin/
    sed -i -e 's/EUARE_URL=/AWS_IAM_URL=/' /root/creds/eucalyptus/admin/eucarc    # invisibly fix deprecation message
    sleep 2
else
    echo
    echo "Could not find Eucalyptus Administrator credentials!"
    exit 3
fi


#  6. Execute Demo

((++step))
clear
echo
echo "============================================================"
echo
echo " $(printf '%2d' $step). Initialize Administrator credentials"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "source /root/creds/eucalyptus/admin/eucarc"

choose "Execute"

if [ $choice = y ]; then
    echo
    echo "# source /root/creds/eucalyptus/admin/eucarc"
    source /root/creds/eucalyptus/admin/eucarc

    choose "Continue"
fi


((++step))
clear
echo
echo "============================================================"
echo
echo " $(printf '%2d' $step). Configure DNS Domain and SubDomain"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "euca-modify-property -p system.dns.dnsdomain = $EUCA_DNS_BASE_DOMAIN"
echo
echo "euca-modify-property -p loadbalancing.loadbalancer_dns_subdomain = $EUCA_DNS_LOADBALANCER_SUBDOMAIN"

choose "Execute"

if [ $choice = y ]; then
    echo
    echo "# euca-modify-property -p system.dns.dnsdomain=$EUCA_DNS_BASE_DOMAIN"
    euca-modify-property -p system.dns.dnsdomain=$EUCA_DNS_BASE_DOMAIN
    echo
    echo "# euca-modify-property -p loadbalancing.loadbalancer_dns_subdomain=$EUCA_DNS_LOADBALANCER_SUBDOMAIN"
    euca-modify-property -p loadbalancing.loadbalancer_dns_subdomain=$EUCA_DNS_LOADBALANCER_SUBDOMAIN

    choose "Continue"
fi


((++step))
clear
echo
echo "============================================================"
echo
echo " $(printf '%2d' $step). Turn on IP Mapping"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "euca-modify-property -p bootstrap.webservices.use_instance_dns=true"
echo
echo "euca-modify-property -p cloud.vmstate.instance_subdomain=$EUCA_DNS_INSTANCE_SUBDOMAIN"

choose "Execute"

if [ $choice = y ]; then
    echo
    echo "# euca-modify-property -p bootstrap.webservices.use_instance_dns=true"
    euca-modify-property -p bootstrap.webservices.use_instance_dns=true
    echo
    echo "# euca-modify-property -p cloud.vmstate.instance_subdomain=$EUCA_DNS_INSTANCE_SUBDOMAIN"
    euca-modify-property -p cloud.vmstate.instance_subdomain=$EUCA_DNS_INSTANCE_SUBDOMAIN

    choose "Continue"
fi


((++step))
clear
echo
echo "============================================================"
echo
echo " $(printf '%2d' $step). Enable DNS Delegation"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "euca-modify-property -p bootstrap.webservices.use_dns_delegation=true"

choose "Execute"

if [ $choice = y ]; then
    echo
    echo "# euca-modify-property -p bootstrap.webservices.use_dns_delegation=true"
    euca-modify-property -p bootstrap.webservices.use_dns_delegation=true

    choose "Continue"
fi


((++step))
clear
echo
echo "============================================================"
echo
echo " $(printf '%2d' $step). Refresh Administrator Credentials"
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
echo "source /root/creds/eucalyptus/admin/eucarc"

choose "Execute"

if [ $choice = y ]; then
    echo
    echo "# rm -f /root/admin.zip"
    rm -f /root/admin.zip
    pause

    echo "# euca-get-credentials -u admin /root/admin.zip"
    euca-get-credentials -u admin /root/admin.zip
    pause

    echo "# rm -Rf /root/creds/eucalyptus/admin"
    rm -Rf /root/creds/eucalyptus/admin
    echo
    echo "# mkdir -p /root/creds/eucalyptus/admin"
    mkdir -p /root/creds/eucalyptus/admin
    echo
    echo "# unzip /root/admin.zip -d /root/creds/eucalyptus/admin/"
    unzip /root/admin.zip -d /root/creds/eucalyptus/admin/
    sed -i -e 's/EUARE_URL=/AWS_IAM_URL=/' /root/creds/eucalyptus/admin/eucarc    # invisibly fix deprecation message
    if [ -r /root/eucarc ]; then
        cp /root/creds/eucalyptus/admin/eucarc /root/eucarc    # invisibly update Faststart credentials location
    fi
    pause

    echo "# source /root/creds/eucalyptus/admin/eucarc"
    source /root/creds/eucalyptus/admin/eucarc

    choose "Continue"
fi


echo
echo "Eucalyptus DNS configured"