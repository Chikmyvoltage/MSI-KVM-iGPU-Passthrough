#!/usr/bin/env bash

# Special thanks to:
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
#
# qemu-img create -f qcow2 mac_hdd_ng.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

MY_OPTIONS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# This script works for Big Sur, Catalina, Mojave, and High Sierra. Tested with
# macOS 10.15.6, macOS 10.14.6, and macOS 10.13.6

ALLOCATED_RAM="8192" # MiB
CPU="host"

REPO_PATH="."
IMAGES_PATH="/var/lib/libvirt/images/macOS"
#EDK2_OVMF="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
#EDK2_OVMF_VARS="$REPO_PATH/OVMF_VARS_ext.fd"

#EDK2_OVMF="$REPO_PATH/OVMF/OVMF_CODE.fd"
#EDK2_OVMF_VARS="$REPO_PATH/OVMF/OVMF_VARS-1024x768.fd"

EDK2_OVMF="/usr/share/ovmf/x64/OVMF_CODE.4m.fd"
EDK2_OVMF_VARS="$REPO_PATH/OVMF_VARS_ext.fd"

OVMF_DIR="OVMF"
I915_OVMF_DIR="i915ovmf"
# This causes high cpu usage on the *host* side
# qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,hypervisor=off,vmx=on,kvm=off,$MY_OPTIONS\

# shellcheck disable=SC2054
args=(
  -enable-kvm -m "$ALLOCATED_RAM" -cpu "$CPU",kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"
  -machine q35,smm=on,accel=kvm
  -smp 8,sockets=1,cores=8
  -overcommit mem-lock=off
  -vga none -nographic
#  -vga vmware
  -device vfio-pci,sysfsdev=/sys/bus/pci/devices/0000:00:02.0/2aee154e-7d0d-11e8-88b8-6f45320c7162,addr=02.0,display=on,x-igd-opregion=on,x-no-geforce-quirks=on,romfile="$REPO_PATH/i915ovmf/build.rom"
#  -device vfio-pci,host=0000:00:02.0,id=hostdev0,bus=pcie.0,addr=0x2,romfile="$REPO_PATH/i915ovmf/build.rom"
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$EDK2_OVMF"
  -drive if=pflash,format=raw,file="$EDK2_OVMF_VARS"
  -smbios type=1,serial=C02YLYZGKGYG,product="MacBookPro15,,1"
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore-Catalina/OCBOOT.qcow2"
#  -device ide-hd,bus=sata.1,drive=BackupVirtualDisk
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot,bootindex=1
  -drive id=MacHDD,if=none,file="$IMAGES_PATH/macSequoia.img",format=qcow2
#  -drive id=BackupVirtualDisk,if=none,file="$IMAGES_PATH/sequoia.img",format=raw
  -device ide-hd,bus=sata.4,drive=MacHDD
  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=00:16:CB:00:22:5B
  -device qemu-xhci,p2=8,p3=8
  -display gtk,gl=on,grab-on-hover=off
  -usb
  -device usb-tablet
  -device usb-kbd
)

qemu-system-x86_64 "${args[@]}"
