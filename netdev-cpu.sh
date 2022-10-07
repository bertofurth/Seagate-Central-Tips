#!/bin/bash
# Set the CPU affinity for networking to CPU 1. This assumes
# that all the other IRQs (such as timing) will fire on CPU 0.
#
# install as follows as the root user
#
# cp netdev-cpu.sh /etc/init.d/
# chmod u+x /etc/init.d/netdev-cpu.sh
# update-rc.d netdev-cpu.sh start 42 S .
#
# Tests show that this produces *slightly* but not *significantly*
# better networking performance for the Seagate Central.
#
# Based on target/linux/cns3xxx/base-files/etc/init.d/netdev-cpu
# in https://git.openwrt.org/openwrt/openwrt.git commit level 
# ada7322055f0bf9ddace615f97d6d40641925aea
#

get_irq() {
        local name="$1"
        grep -m 1 "$name" /proc/interrupts | cut -d: -f1 | sed 's, *,,'
}

set_irq_affinity() {
        local name="$1"
        local val="$2"
        local irq="$(get_irq "$name")"
        [ -n "$irq" ] || return
	echo "Setting CPU affinity bitmask of irq $name ($irq) to $val"
        echo "$val" > "/proc/irq/$irq/smp_affinity"
}

NUM_CPUS=$(getconf _NPROCESSORS_ONLN)
echo "Number of CPUs online : $NUM_CPUS"
ONE_CPU_ONLY=$(echo $NUM_CPUS| grep "1")
if [ -z $ONE_CPU_ONLY ]; then
	set_irq_affinity gig_switch 2
	set_irq_affinity gig_stat 2
fi

