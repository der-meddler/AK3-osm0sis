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
dump_boot; # unpack the ramdisk: the first-stage fstab (fstab.mt6768 / fstab.mt6769t) lives there

## first-stage fstab: no AVB/dm-verity for the logical (super) partitions, no file-based
## encryption for /data. Pairs with a superkit-built super.img (the vendor copies of the fstab
## get the same edit there) and a verification-disabled vbmeta. Dropping the encryption flags
## requires a freshly formatted /data. The sed expressions only remove whole flag tokens; every
## other byte of the fstab stays as Samsung shipped it, and re-flashing is a no-op.
for fstab in fstab.mt6768 fstab.mt6769t; do
  [ -f $RAMDISK/$fstab ] || continue;
  backup_file $RAMDISK/$fstab;
  # logical partitions (system, system_ext, vendor, product, odm): avb_keys=..., avb=vbmeta_system, avb
  sed -i -e '/,logical,/{s/,avb_keys=[^,[:space:]]*//;s/,avb=[^,[:space:]]*//;s/,avb,/,/;}' $RAMDISK/$fstab;
  # /data: fileencryption=..., keydirectory=..., metadata_encryption=... flags and the inlinecrypt mount option
  sed -i -e '/[[:space:]]\/data[[:space:]]/{s/,fileencryption=[^,[:space:]]*//;s/,keydirectory=[^,[:space:]]*//;s/,metadata_encryption=[^,[:space:]]*//;s/,inlinecrypt\([,[:space:]]\)/\1/;}' $RAMDISK/$fstab;
  # the prism/optics/vbmeta_system lines legitimately keep their avb flags, so only check what was edited
  grep ',logical,' $RAMDISK/$fstab | grep -q 'avb' && abort "fstab patch failed on $fstab (avb left on a logical partition). Aborting...";
  grep '[[:space:]]/data[[:space:]]' $RAMDISK/$fstab | grep -q 'fileencryption=\|keydirectory=\|inlinecrypt' && abort "fstab patch failed on $fstab (/data still encrypted). Aborting...";
done;

write_boot; # repacks the ramdisk (gzip, as found) and flashes boot
## end boot install

