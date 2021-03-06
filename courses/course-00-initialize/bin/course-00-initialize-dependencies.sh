#!/bin/bash
#
# This script initializes dependencies prior to installing Eucalyptus
#
# This script should be run on all hosts.
#
# This script isn't smart enough to figure out various network modes, and is
# currently hard-coded for the course's use of the MANANGED-NOVLAN mode
#

#  1. Initalize Environment

if [ -z $EUCA_VNET_MODE ]; then
    echo "Please set environment variables first"
    exit 3
fi

[ "$(hostname -s)" = "$EUCA_CLC_HOST_NAME" ] && is_clc=y || is_clc=n
[ "$(hostname -s)" = "$EUCA_UFS_HOST_NAME" ] && is_ufs=y || is_ufs=n
[ "$(hostname -s)" = "$EUCA_MC_HOST_NAME" ]  && is_mc=y  || is_mc=n
[ "$(hostname -s)" = "$EUCA_CC_HOST_NAME" ]  && is_cc=y  || is_cc=n
[ "$(hostname -s)" = "$EUCA_SC_HOST_NAME" ]  && is_sc=y  || is_sc=n
[ "$(hostname -s)" = "$EUCA_OSP_HOST_NAME" ] && is_osp=y || is_osp=n
[ "$(hostname -s)" = "$EUCA_NC1_HOST_NAME" ] && is_nc=y  || is_nc=n
[ "$(hostname -s)" = "$EUCA_NC2_HOST_NAME" ] && is_nc=y
[ "$(hostname -s)" = "$EUCA_NC3_HOST_NAME" ] && is_nc=y
[ "$(hostname -s)" = "$EUCA_NC4_HOST_NAME" ] && is_nc=y

bindir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
confdir=${bindir%/*}/conf
docdir=${bindir%/*}/doc
logdir=${bindir%/*}/log
scriptsdir=${bindir%/*}/scripts
templatesdir=${bindir%/*}/templates
tmpdir=/var/tmp
prefix=course

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


#  5. Execute Course Lab

start=$(date +%s)

((++step))
if [ $is_clc = y ]; then
    need_ips="$EUCA_CLC_PUBLIC_IP"
    [[ $need_ips =~ .*${EUCA_UFS_PUBLIC_IP//./\.}.* ]] || need_ips="$need_ips $EUCA_UFS_PUBLIC_IP"
    [[ $need_ips =~ .*${EUCA_MC_PUBLIC_IP//./\.}.* ]]  || need_ips="$need_ips $EUCA_MC_PUBLIC_IP"
    [[ $need_ips =~ .*${EUCA_CC_PUBLIC_IP//./\.}.* ]]  || need_ips="$need_ips $EUCA_CC_PUBLIC_IP"
    [[ $need_ips =~ .*${EUCA_SC_PUBLIC_IP//./\.}.* ]]  || need_ips="$need_ips $EUCA_SC_PUBLIC_IP"
    [[ $need_ips =~ .*${EUCA_OSP_PUBLIC_IP//./\.}.* ]] || need_ips="$need_ips $EUCA_OSP_PUBLIC_IP"
    [[ $need_ips =~ .*${EUCA_NC1_PRIVATE_IP//./\.}.* ]] || need_ips="$need_ips $EUCA_NC1_PRIVATE_IP"
    [[ $need_ips =~ .*${EUCA_NC2_PRIVATE_IP//./\.}.* ]] || need_ips="$need_ips $EUCA_NC2_PRIVATE_IP"
    [[ $need_ips =~ .*${EUCA_NC3_PRIVATE_IP//./\.}.* ]] || need_ips="$need_ips $EUCA_NC3_PRIVATE_IP"
    [[ $need_ips =~ .*${EUCA_NC4_PRIVATE_IP//./\.}.* ]] || need_ips="$need_ips $EUCA_NC4_PRIVATE_IP"

    ips=""
    for ip in $need_ips; do 
        if ! grep -s -q $ip /root/.ssh/known_hosts; then
            ips="$ips $ip"
        fi
    done
    ips="${ips# }"
    
    if [ -z $ips ]; then
        clear
        echo
        echo "============================================================"
        echo
        echo "$(printf '%2d' $step). Scan for unknown SSH host keys"
        echo "    - No unknown IPs!"
        echo
        echo "============================================================"
        echo

        next 50

    else
        clear
        echo
        echo "============================================================"
        echo
        echo "$(printf '%2d' $step). Scan for unknown SSH host keys"
        echo "    - Scan for and collect any unknown SSH host keys associated"
        echo "      with other hosts in the cluster, to prevent \"Unknown host\""
        echo "      warnings with acceptance prompts during the install"
        echo
        echo "============================================================"
        echo
        echo "Commands:"
        echo
        for ip in $ips; do
            if ! grep -s -q $ip /root/.ssh/known_hosts; then
                echo "ssh-keyscan $ip 2> /dev/null >> /root/.ssh/known_hosts"
            fi
        done
    
        run 50
    
        if [ $choice = y ]; then
            echo
            for ip in $ips; do
                if ! grep -s -q $ip /root/.ssh/known_hosts; then
                    echo "# ssh-keyscan $ip 2> /dev/null >> /root/.ssh/known_hosts"
                    ssh-keyscan $ip 2> /dev/null >> /root/.ssh/known_hosts
                fi
            done
    
            next 50
        fi
    fi
fi


((++step))
if [ $is_cc = y -o $is_nc = y ]; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Disable ZEROCONF networking"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "sed -i -e '/NOZEROCONF=/d' -e '$a\NOZEROCONF=yes' /etc/sysconfig/network"

    run

    if [ $choice = y ]; then
        echo
        echo "# sed -i -e '/NOZEROCONF=/d' -e '$a\NOZEROCONF=yes' /etc/sysconfig/network"
        sed -i -e '/NOZEROCONF=/d' -e '$a\NOZEROCONF=yes' /etc/sysconfig/network

        next
    fi
fi


((++step))
if [ $is_cc = y -o $is_nc = y ]; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Install bridge utilities package"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "yum -y install bridge-utils"

    run

    if [ $choice = y ]; then
        echo
        echo "# yum -y install bridge-utils"
        yum -y install bridge-utils

        next
    fi
fi


((++step))
if [ $is_nc = y ]; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Create bridge"
    echo "    - This bridge connects between the public ethernet adapter"
    echo "      and virtual machine instance virtual ethernet adapters"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "echo << EOF > /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE"
    echo "DEVICE=$EUCA_VNET_BRIDGE"
    echo "TYPE=Bridge"
    echo "BOOTPROTO=dhcp"
    echo "PERSISTENT_DHCLIENT=yes"
    echo "ONBOOT=yes"
    echo "DELAY=0"
    echo "EOF"

    run

    if [ $choice = y ]; then
        echo
        echo "# echo << EOF > /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE"
        echo "> DEVICE=$EUCA_VNET_BRIDGE"
        echo "> TYPE=Bridge"
        echo "> BOOTPROTO=dhcp"
        echo "> PERSISTENT_DHCLIENT=yes"
        echo "> ONBOOT=yes"
        echo "> DELAY=0"
        echo "> EOF"
        echo "DEVICE=$EUCA_VNET_BRIDGE"  > /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE
        echo "TYPE=Bridge"              >> /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE
        echo "BOOTPROTO=dhcp"           >> /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE
        echo "PERSISTENT_DHCLIENT=yes"  >> /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE
        echo "ONBOOT=yes"               >> /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE
        echo "DELAY=0"                  >> /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_BRIDGE

        next
    fi
fi


((++step))
if [ $is_nc = y ]; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Adjust public ethernet interface"
    echo "    - Associate the interface with the bridge"
    echo "    - Remove the interface's IP address (moves to bridge)"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "sed -i -e \"\\\$aBRIDGE=$EUCA_VNET_BRIDGE\" \\"
    echo "       -e \"/^BOOTPROTO=/s/=.*\$/=none/\" \\"
    echo "       -e \"/^PERSISTENT_DHCLIENT=/d\" \\"
    echo "       -e \"/^DNS.=/d\" /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_PRIVINTERFACE"

    run

    if [ $choice = y ]; then
        echo
        echo "# sed -i -e \"\\\$aBRIDGE=$EUCA_VNET_BRIDGE\" \\"
        echo ">        -e \"/^BOOTPROTO=/s/=.*\$/=none/\" \\"
        echo ">        -e \"/^PERSISTENT_DHCLIENT=/d\" \\"
        echo ">        -e \"/^DNS.=/d\" /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_PRIVINTERFACE"
        sed -i -e "\$aBRIDGE=$EUCA_VNET_BRIDGE" \
               -e "/^BOOTPROTO=/s/=.*$/=none/" \
               -e "/^PERSISTENT_DHCLIENT=/d" \
               -e "/^DNS.=/d" /etc/sysconfig/network-scripts/ifcfg-$EUCA_VNET_PRIVINTERFACE

        next
    fi
fi


((++step))
if [ $is_cc = y -o $is_nc = y ]; then
    clear
    echo
    echo "============================================================"
    echo
    echo "$(printf '%2d' $step). Restart networking"
    echo "    - Can lose connectivity here, make sure you have alternate way in"
    echo
    echo "============================================================"
    echo
    echo "Commands:"
    echo
    echo "service network restart"

    run 50

    if [ $choice = y ]; then
        echo
        echo "# service network restart"
        service network restart

        next 50
    fi
fi


((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Disable firewall"
echo "    - To prevent unexpected issues"
echo "    - Can be re-enabled after setup with appropriate ports open"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "service iptables stop"

run 50

if [ $choice = y ]; then
    echo
    echo "# service iptables stop"
    service iptables stop

    next 50
fi


((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Disable SELinux"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "sed -i -e \"/^SELINUX=/s/=.*\$/=permissive/\" /etc/selinux/config"
echo
echo "setenforce 0"

run 50

if [ $choice = y ]; then
    echo
    echo "# sed -i -e \"/^SELINUX=/s/=.*\$/=permissive/\" /etc/selinux/config"
    sed -i -e "/^SELINUX=/s/=.*$/=permissive/" /etc/selinux/config
    pause

    echo "# setenforce 0"
    setenforce 0

    next 50
fi


((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Install and Configure the NTP service"
echo "    - It is critical that NTP be running and accurate on all hosts"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "yum -y install ntp"
echo
echo "chkconfig ntpd on"
echo "service ntpd start"
echo
echo "ntpdate -u  0.centos.pool.ntp.org"
echo "hwclock --systohc"

run

if [ $choice = y ]; then
    echo
    echo "# yum -y install ntp"
    yum -y install ntp
    pause

    echo "# chkconfig ntpd on"
    chkconfig ntpd on
    echo "# service ntpd start"
    service ntpd start
    pause

    echo "# ntpdate -u  0.centos.pool.ntp.org"
    ntpdate -u  0.centos.pool.ntp.org
    echo "# hwclock --systohc"
    hwclock --systohc

    next 50
fi


# Skipping mail relay config for now
# Just talked to Kyle yesterday about how we do this, still need to write the code
# to use GMail as relay and then test it. May need to add parameter to specify email
# address of user running this script.


((++step))
clear
echo
echo "============================================================"
echo
echo "$(printf '%2d' $step). Configure packet routing"
echo
echo "============================================================"
echo
echo "Commands:"
echo
echo "sed -i -e '/^net.ipv4.ip_forward = 0/s/=.*$/= 1/' /etc/sysctl.conf"
if [ -e /proc/sys/net/bridge/bridge-nf-call-iptables ]; then
    echo "sed -i -e '/^net.bridge.bridge-nf-call-iptables = 0/s/=.*$/= 1/' /etc/sysctl.conf"
fi
echo
echo "sysctl -p"
echo
echo "cat /proc/sys/net/ipv4/ip_forward"
if [ -e /proc/sys/net/bridge/bridge-nf-call-iptables ]; then
    echo "cat /proc/sys/net/bridge/bridge-nf-call-iptables"
fi

run

if [ $choice = y ]; then
    echo
    echo "# sed -i -e '/^net.ipv4.ip_forward = 0/s/=.*$/= 1/' /etc/sysctl.conf"
    sed -i -e '/^net.ipv4.ip_forward = 0/s/=.*$/= 1/' /etc/sysctl.conf
    if [ -e /proc/sys/net/bridge/bridge-nf-call-iptables ]; then
        echo "# sed -i -e '/^net.bridge.bridge-nf-call-iptables = 0/s/=.*$/= 1/' /etc/sysctl.conf"
        sed -i -e '/^net.bridge.bridge-nf-call-iptables = 0/s/=.*$/= 1/' /etc/sysctl.conf
    fi
    pause

    echo "# sysctl -p"
    sysctl -p 2> /dev/null    # prevent display of missing bridge errors
    pause

    echo "# cat /proc/sys/net/ipv4/ip_forward"
    cat /proc/sys/net/ipv4/ip_forward
    if [ -e /proc/sys/net/bridge/bridge-nf-call-iptables ]; then
        echo "cat /proc/sys/net/bridge/bridge-nf-call-iptables"
        cat /proc/sys/net/bridge/bridge-nf-call-iptables
    fi

    next
fi


end=$(date +%s)

echo
case $(uname) in
  Darwin)
    echo "Dependencies initialized (time: $(date -u -r $((end-start)) +"%T"))";;
  *)
    echo "Dependencies initialized (time: $(date -u -d @$((end-start)) +"%T"))";;
esac
