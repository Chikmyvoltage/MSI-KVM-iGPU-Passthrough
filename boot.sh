# Set your iGPU pci id (fetched from lspci)
IGPU_PCIID="8086 3E8B"

modprobe vfio_pci
modprobe vfio
echo $IGPU_PCIID > /sys/bus/pci/drivers/vfio-pci/new_id
modprobe -r i915

sleep 2

./opencore-boot-pt.sh

sleep 2

modprobe -r vfio_pci
modprobe -r vfio
modprobe i915
