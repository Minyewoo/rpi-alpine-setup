# Features 
[x] SD carsd setup
[x] On-device install
[ ] Window system setup


# Installation guide
## 1. SD card setup
Insert sd card into your main machine.

Specify sd card device (for example `/dev/sdb`).

Run the following command for your sd card device:
```sh
    ./src/alpine_burn_sd.sh -d <sd-card-device>
```

If any error occured, I suggest to replug your cardreader or remove all partitions on sd card, then run the script again.

Unmount all sd card partitions (for example, exect it from Nautilus) and remove sd card from the port.

## 2. Installation on Raspberry pi (tested for RPI 3).
Insert sd card into your raspberry pi.

Plug in all cables including ethernet (required). **CAUTION**: plug in power cable last.

Log in with root.

Run the following commands (don't forget to specify all args) and do not answer on promt questions yourself - it will be done automatically:
```sh
cp /media/mmcblk0p1/alpine_ondevice_install.sh ./
```
```sh
./alpine_ondevice_install.sh -r <root-password> -n <new-user-name> -p <new-user-password>
```

## 3. Adding user to admin group

After RPI reboots login as root and run the following commands:

```sh
adduser objdetect wheel
```
```sh
echo "permit persist :wheel" >> /etc/doas.conf
```
```sh
reboot
```

## 4. Window system setup

You are able to see your IP address on network in OpenRC startup logs.
Transfer setup script from your main machine:
```sh
scp src/alpine_postreboot.sh <new-user-name>@<rpi-ip-address>:/home/<new-user-name>
```

Do not try with `... root@...`- it's banned by default.

After transfer login as `<new-user-name>` and run:
```sh
./alpine_postreboot.sh
```
