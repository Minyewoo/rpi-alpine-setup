# Reading command line arguments
while getopts r:n:p: flag
do
    case "${flag}" in
        r) root_pass=${OPTARG};;
        n) user_name=${OPTARG};;
        p) user_pass=${OPTARG};;
    esac
done

# Exiting if any of the arguments is not set
if [[ -z "$root_pass" ]]; then
    >&2 echo "Error! Please specify root password with -r argument"
    exit 2
fi

if [[ -z "$user_name" ]]; then
    >&2 echo "Error! Please specify new user name with -n argument"
    exit 2
fi

if [[ -z "$user_pass" ]]; then
    >&2 echo "Error! Please specify new user password with -p argument"
    exit 2
fi

# Copying answers for setup-alpine script from sd card, overwise we can't unmount and repartition it, cause it's blocks
cp /media/mmcblk0p1/setup-alpine.in ./

# Begining installation process and passing answers to it
printf "$root_pass\n$root_pass\n$user_name\n$user_name\n$user_pass\n$user_pass\nnone\ny\ny\n" | setup-alpine -f setup-alpine.in

reboot


