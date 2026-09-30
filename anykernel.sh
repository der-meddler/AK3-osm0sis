### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers
## Galaxy A13 SM-A137F (a13ve) setup by der-meddler & Claude

### AnyKernel setup
# global properties
properties() { '
kernel.string=ReSukiSU kernel for Galaxy A13 (SM-A137F) by der-meddler & Claude
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=a13ve
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
# boot shell variables
BLOCK=boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto; # never none/cpio: magiskboot then skips all compression and a raw Image won't fit the 32 MiB partition
PATCH_VBMETA_FLAG=0; # leave boot's own vbmeta flags alone, the top-level vbmeta must already be disabled
NO_MAGISK_CHECK=1; # root is ReSukiSU in the kernel, skip Magisk detection and kernel/dtb re-patching

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# without a kernel in the zip flash_boot would silently reflash the current one
[ -f Image.gz -o -f Image ] || abort "No kernel Image found in zip. Aborting...";

# boot install
split_boot; # kernel-only zip: skip ramdisk unpack, the existing ramdisk is repacked untouched

flash_boot; # must stay paired with split_boot, switch both to dump_boot/write_boot before adding ramdisk edits
## end boot install

