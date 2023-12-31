# Usage: ./alpine_burn_sd.sh -d /dev/sda
while getopts d: flag
do
    case "${flag}" in
        # please, specify the right one sd card device path
        d) sd_dev=${OPTARG};;
    esac
done

if [[ -z "$sd_dev" ]]; then
    >&2 echo "Error! Please specify the -d argument"
    exit 2
fi

# installing required dependencies
sudo apt-get -qq install dosfstools syslinux -y

# umounting all sd card partitions if any
sudo umount -q $sd_dev?

# wipe MBR on sd card
sudo dd if=/dev/zero of=$sd_dev bs=512 count=1

# create MBR
sudo parted -s $sd_dev mklabel msdos
# create first partition for fat32 filesystem
sudo parted -s -a opt $sd_dev mkpart primary fat32 0% 513MB
# create second partition for ext4 filesystem
#sudo parted -a opt $sd_dev mkpart primary ext4 513MB 100%

# formatting partition 1 with FAT32 filesystem
sudo mkdosfs -F32 ${sd_dev}1

# formatting partition 2 with ext4 filesystem
#sudo mkfs -F -t ext4 ${sd_dev}2

# finding syslinux mbr location
syslinux_mbr=$(sudo find /usr -iname 'mbr.bin' | awk 'NR==1{print $1;}')

# copying syslinux executable to the MBR boot sector
sudo dd bs=440 count=1 conv=notrunc if=$syslinux_mbr of=$sd_dev

# installing bootloader onto the filesystem
sudo syslinux ${sd_dev}1


tarball_name=alpine-rpi-3.18.4-aarch64.tar.gz
tarball_path=$HOME/Downloads/$tarball_name
tarball_url=https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/$tarball_name

# downloading alpine linux if not already
if [ ! -f $tarball_path ]; then
    echo "Downloading Alpine Linux..."
    wget $tarball_url -P $HOME/Downloads/
fi

# copying contents of Alpine tarball to the sd card FAT32 filesystem
sd_dev_name=$(basename $sd_dev)1
sudo mkdir -p /media/$sd_dev_name
sudo mount -t vfat ${sd_dev}1 /media/$sd_dev_name
sudo tar -p -s --atime-preserve --same-owner --one-top-level=/media/$sd_dev_name -zxf "$tarball_path"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# copying helper files for on-device setup
sudo cp $SCRIPT_DIR/setup-alpine.in /media/$sd_dev_name
sudo cp $SCRIPT_DIR/alpine_ondevice_install.sh /media/$sd_dev_name
# sudo cp $SCRIPT_DIR/network_interfaces /media/$sd_dev_name
# sudo cp $SCRIPT_DIR/hosts /media/$sd_dev_name

# task completed - we can unmount
sudo umount /media/$sd_dev_name