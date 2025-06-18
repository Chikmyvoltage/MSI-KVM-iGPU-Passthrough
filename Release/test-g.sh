#!/bin/bash
export WORKSPACE=/home/$(whoami)/Templates/OSX_GVT-D/Release
export PCILOC=00:02.0
export PCIID=8086:3e9b
export GVTMODE=i915-GVTg_V5_4


cd ./i915_simple

qemu-system-x86_64 -k en-us -name uefitest,debug-threads=on -serial stdio -m 2048 -M pc -cpu host -global PIIX4_PM.disable_s3=1 -global PIIX4_PM.disable_s4=1 -machine kernel_irqchip=on -nodefaults -rtc base=localtime,driftfix=slew -global kvm-pit.lost_tick_policy=discard -enable-kvm -bios $WORKSPACE/../OVMF/OVMF_CODE.fd -display gtk,gl=on,grab-on-hover=on -full-screen -vga none -device vfio-pci,sysfsdev=/sys/bus/pci/devices/0000:$PCILOC/2aee154e-7d0d-11e8-88b8-6f45320c7162,addr=02.0,display=on,x-igd-opregion=on,romfile=`pwd`/i915ovmf.rom -device qemu-xhci,p2=8,p3=8 -device usb-kbd -device usb-tablet -drive format=raw,file="$WORKSPACE/disk"
