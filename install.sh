#!/bin/bash

############################################################
# Assert                                                   #
############################################################
Assert(){

    for arg in "$@"; do

        if [ "${!arg}" = "" ];then
            print_stack "Missing $arg in .env"
            exit 1
        fi

    done

}
############################################################
############################################################
# Help                                                     #
############################################################
Help(){
  echo ""
  echo "Install cron job that check if server ip has changed compared"
  echo "to what is registered at loopia. Please make sure that"
  echo "you have runnned 'cp sample.env .env' and added credentials to"
  echo "to .env"
  echo ""
  echo "Usage:"
  echo  "monitor.sh [options]"
  echo "monitor.sh -h|-help"
  echo ""
  echo "Options":
  echo " -h, --help            Display help text"
  echo ""
}
############################################################

NAME_SCRIPT="loopia-dns.sh"
NAME_CRON="loopia-dns-cron"
PATH_CRON="/etc/cron.d"

if [ ! -f ".env" ]; then
  echo "Missing .env. Please add the file"
  exit
fi


while [ ! -z $1 ]; do

   arg=$1; shift

   case "$arg" in
    -h | --help) Help; exit;;
    *) echo "Uknown option ..."; exit;;
    esac
done

export $(cat .env | xargs)

Assert "HOSTNAME" "PASSWORD" "MAILTO"

echo "Creating $NAME_SCRIPT using credentials in .env"
cp sample.$NAME_SCRIPT $NAME_SCRIPT
sed -i "s#{hostname}#$HOSTNAME#g" $NAME_SCRIPT
sed -i "s#{password}#$PASSWORD#g" $NAME_SCRIPT
sed -i "s#{mailto}#$MAILTO#g" $NAME_SCRIPT


echo "Creating $NAME_CRON"
cp sample.$NAME_CRON $NAME_CRON
sed -i "s#{user}#$USER#g" $NAME_CRON
sed -i "s#{src}#$(pwd)#g" $NAME_CRON


echo "Mv $NAME_CRON to $PATH_CRON. Need to use sudo ..."
sudo mv $NAME_CRON ${PATH_CRON}/${NAME_CRON}
sudo chown root:root ${PATH_CRON}/${NAME_CRON}

echo "Done!"


