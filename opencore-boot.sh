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

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# This script works for Big Sur, Catalina, Mojave, and High Sierra. Tested with
# macOS 10.15.6, macOS 10.14.6, and macOS 10.13.6

ALLOCATED_RAM="6122" # MiB
CPU="host"

REPO_PATH="."
IMAGES_PATH="/var/lib/libvirt/images/macOS"
EDK2_OVMF="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
EDK2_OVMF_VARS="$REPO_PATH/OVMF_VARS.4m.fd"
OVMF_DIR="OVMF"
I915_OVMF_DIR="i915ovmf"

# This causes high cpu usage on the *host* side
# qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,hypervisor=off,vmx=on,kvm=off,$MY_OPTIONS\

# shellcheck disable=SC2054
args=(
  -enable-kvm -m "$ALLOCATED_RAM" -cpu "$CPU",kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"
  -drive if=pflash,format=raw,readonly=on,file="$EDK2_OVMF",node-name=pflash-storage0
  -drive if=pflash,format=raw,file="$EDK2_OVMF_VARS",node-name=pflash-storage1
  -machine q35,accel=kvm,hpet=off,acpi=on
  -vga vmware
  -boot strict=on
  -smp 12,sockets=12,cores=1,threads=1
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -smbios type=2
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$IMAGES_PATH/OpenCore.qcow2"
  -device ide-hd,bus=sata.0,drive=OpenCoreBoot,bootindex=1
  -device ide-hd,bus=sata.1,drive=InstallMedia
  -drive id=InstallMedia,if=none,file="$IMAGES_PATH/BaseSystem.img",format=raw
  -drive id=MacHDD,if=none,file="$IMAGES_PATH/macSonoma.img",format=qcow2
  -device ide-hd,bus=sata.2,drive=MacHDD
  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27
  -usb
  -device usb-tablet
  -device usb-kbd
)

qemu-system-x86_64 "${args[@]}"
