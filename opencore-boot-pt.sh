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

ALLOCATED_RAM="4092" # MiB
CPU="Haswell-noTSX"

REPO_PATH="."
IMAGES_PATH="/var/lib/libvirt/images/macOS"
#EDK2_OVMF="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
#EDK2_OVMF_VARS="$REPO_PATH/OVMF_VARS_ext.fd"

EDK2_OVMF="$REPO_PATH/OVMF/OVMF_CODE.fd"
EDK2_OVMF_VARS="$REPO_PATH/OVMF/OVMF_VARS-1024x768.fd"

OVMF_DIR="OVMF"
I915_OVMF_DIR="i915ovmf"
# This causes high cpu usage on the *host* side
# qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,hypervisor=off,vmx=on,kvm=off,$MY_OPTIONS\

# shellcheck disable=SC2054
args=(
  -enable-kvm -m "$ALLOCATED_RAM" -cpu "$CPU",kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"
  -machine q35
  -smp 12,sockets=12,cores=1,threads=1
  -overcommit mem-lock=off
  -vga none -nographic
  -device vfio-pci,host=0000:00:02.0,id=hostdev0,bus=pcie.0,addr=0x2,romfile="$REPO_PATH/i915ovmf/build.rom"
  -fw_cfg name=opt/etc/igd-opregion,file="$REPO_PATH/i915ovmf/opregion.bin"
  -fw_cfg name=opt/etc/igd-bdsm-size,file="$REPO_PATH/i915ovmf/bdsmSize.bin"
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$EDK2_OVMF"
  -drive if=pflash,format=raw,file="$EDK2_OVMF_VARS"
  -smbios type=2
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore-Catalina/OCBOOT.qcow2"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot,bootindex=1
  -device ide-hd,bus=sata.3,drive=InstallMedia,bootindex=3
  -drive id=InstallMedia,if=none,file="$IMAGES_PATH/BaseSystem.img",format=raw
  -drive id=MacHDD,if=none,file="$IMAGES_PATH/macSonoma.img",format=qcow2
  -device ide-hd,bus=sata.4,drive=MacHDD,bootindex=2
  -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=84:AD:8D:C9:CA:77
  -usb
  -device usb-tablet
  -device usb-kbd
)

qemu-system-x86_64 "${args[@]}"
