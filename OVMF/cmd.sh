/usr/bin/qemu-system-x86_64 
  -name guest=macOS,debug-threads=on -S 
  -object {"qom-type":"secret","id":"masterKey0","format":"raw","file":"/var/lib/libvirt/qemu/domain-15-macOS/master-key.aes"} 
  -blockdev {"driver":"file","filename":"/usr/share/edk2/x64/OVMF_CODE.4m.fd","node-name":"libvirt-pflash0-storage","auto-read-only":true,"discard":"unmap"} 
  -blockdev {"node-name":"libvirt-pflash0-format","read-only":true,"driver":"raw","file":"libvirt-pflash0-storage"} 
  -blockdev {"driver":"file","filename":"/usr/share/edk2/x64/OVMF_VARS.4m.fd","node-name":"libvirt-pflash1-storage","read-only":false} 
  -machine pc-q35-4.2,usb=off,dump-guest-core=off,memory-backend=pc.ram,pflash0=libvirt-pflash0-format,pflash1=libvirt-pflash1-storage,hpet=off,acpi=on 
  -accel kvm 
  -cpu qemu64 
  -m size=8318976k 
  -object {"qom-type":"memory-backend-ram","id":"pc.ram","size":8518631424} 
  -overcommit mem-lock=off 
  -smp 12,sockets=1,dies=1,clusters=1,cores=2,threads=6 
  -uuid 2aca0dd6-cec9-4717-9ab2-0b7b13d111c3 
  -no-user-config 
  -nodefaults 
  -chardev socket,id=charmonitor,fd=33,server=on,wait=off 
  -mon chardev=charmonitor,id=monitor,mode=control 
  -rtc base=utc,driftfix=slew 
  -global kvm-pit.lost_tick_policy=delay 
  -no-shutdown 
  -boot strict=on 
  -device {"driver":"pcie-root-port","port":8,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x1"} 
  -device {"driver":"pcie-root-port","port":9,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x1.0x1"} 
  -device {"driver":"pcie-root-port","port":10,"chassis":3,"id":"pci.3","bus":"pcie.0","addr":"0x1.0x2"} 
  -device {"driver":"pcie-root-port","port":11,"chassis":4,"id":"pci.4","bus":"pcie.0","addr":"0x1.0x3"} 
  -device {"driver":"pcie-root-port","port":12,"chassis":5,"id":"pci.5","bus":"pcie.0","addr":"0x1.0x4"} 
  -device {"driver":"pcie-root-port","port":13,"chassis":6,"id":"pci.6","bus":"pcie.0","addr":"0x1.0x5"} 
  -device {"driver":"pcie-root-port","port":14,"chassis":7,"id":"pci.7","bus":"pcie.0","addr":"0x1.0x6"} 
  -device {"driver":"pcie-root-port","port":15,"chassis":8,"id":"pci.8","bus":"pcie.0","addr":"0x1.0x7"} 
  -device {"driver":"pcie-pci-bridge","id":"pci.9","bus":"pci.3","addr":"0x0"} 
  -device {"driver":"ich9-usb-ehci1","id":"usb","bus":"pcie.0","addr":"0x7.0x7"} 
  -device {"driver":"ich9-usb-uhci1","masterbus":"usb.0","firstport":0,"bus":"pcie.0","multifunction":true,"addr":"0x7"} 
  -device {"driver":"ich9-usb-uhci2","masterbus":"usb.0","firstport":2,"bus":"pcie.0","addr":"0x7.0x1"} 
  -device {"driver":"ich9-usb-uhci3","masterbus":"usb.0","firstport":4,"bus":"pcie.0","addr":"0x7.0x2"} 
  -device {"driver":"virtio-serial-pci","id":"virtio-serial0","bus":"pci.2","addr":"0x0"} 
  -blockdev {"driver":"file","filename":"/var/lib/libvirt/images/macOS/OpenCore.qcow2","aio":"threads","node-name":"libvirt-3-storage","auto-read-only":true,"discard":"unmap","cache":{"direct":false,"no-flush":false}} 
  -blockdev {"node-name":"libvirt-3-format","read-only":false,"cache":{"direct":false,"no-flush":false},"driver":"qcow2","file":"libvirt-3-storage","backing":null} 
  -device {"driver":"ide-hd","bus":"ide.0","drive":"libvirt-3-format","id":"sata0-0-0","bootindex":2,"write-cache":"on"} 
  -blockdev {"driver":"file","filename":"/var/lib/libvirt/images/macOS/macSonoma.img","aio":"threads","node-name":"libvirt-2-storage","auto-read-only":true,"discard":"unmap","cache":{"direct":false,"no-flush":false}} 
  -blockdev {"node-name":"libvirt-2-format","read-only":false,"cache":{"direct":false,"no-flush":false},"driver":"qcow2","file":"libvirt-2-storage","backing":null} 
  -device {"driver":"ide-hd","bus":"ide.1","drive":"libvirt-2-format","id":"sata0-0-1","bootindex":1,"write-cache":"on"} 
  -blockdev {"driver":"file","filename":"/var/lib/libvirt/images/macOS/BaseSystem.img","node-name":"libvirt-1-storage","read-only":false,"cache":{"direct":false,"no-flush":false}} 
  -device {"driver":"ide-hd","bus":"ide.2","drive":"libvirt-1-storage","id":"sata0-0-2","bootindex":3,"write-cache":"on"} 
  -netdev {"type":"tap","fd":"34","id":"hostnet0"} 
  -device {"driver":"vmxnet3","netdev":"hostnet0","id":"net0","mac":"52:54:00:e6:85:40","bus":"pci.9","addr":"0x1"} 
  -chardev pty,id=charserial0 
  -device {"driver":"isa-serial","chardev":"charserial0","id":"serial0","index":0} 
  -chardev socket,id=charchannel0,fd=32,server=on,wait=off 
  -device {"driver":"virtserialport","bus":"virtio-serial0.0","nr":1,"chardev":"charchannel0","id":"channel0","name":"org.qemu.guest_agent.0"} 
  -audiodev {"id":"audio1","driver":"spice"} 
  -spice port=0,disable-ticketing=on,image-compression=off,gl=on,rendernode=/dev/dri/by-path/pci-0000:00:02.0-render,seamless-migration=on 
  -device {"driver":"virtio-vga-gl","id":"video0","max_outputs":1,"bus":"pci.1","addr":"0x0"} 
  -global ICH9-LPC.noreboot=off 
  -watchdog-action reset 
  -device isa-applesmc,osk=ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc 
  -smbios type=2 
  -usb 
  -device usb-tablet 
  -device usb-kbd 
  -cpu host,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check 
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny 
  -msg timestamp=on
