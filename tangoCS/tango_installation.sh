# run as : bash filename.sh     bash -x fN.sh prints all commands and their outputs
# tango will be installed at /home/$USER/tangocs

clear
echo "======================="
echo $'Hi Tango user, Welcome'
echo "======================="
echo $'\nVersions used:'
zmqVersion=4.0.7
omniorbVersion=4.2.1 #note : source file is 4.2.1-2
tangoVersion=9.2.5 #note : source file is 9.2.5a.
cd
timer=2
gccVersion="$(gcc --version | grep ^gcc | sed 's/g.*) //g' | cut -c -3)"
echo $'gccVersion:' $"$gccVersion"
echo $'zmqVersion:' $"$zmqVersion"
echo $'omniorbVersion:' $"$omniorbVersion"
echo $'tangoVersion:' $"$tangoVersion"
sleep $timer



echo $'\n\nInstalling 3 necessary base packages like python, mysql and java \n'
sleep $timer
# need python-dev for omniorb make..
echo $'\n\nInstalling python (1 of 3)'
sleep $timer
set -x
sudo apt-get -y install python-dev
set +x
echo $'\n\nInstalling mysql (2a of 3)'
sleep $timer
set -x
export DEBIAN_FRONTEND="noninteractive"
echo "mysql-server-5.6 mysql-server/root_password password password" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password password" | sudo debconf-set-selections
sudo apt-get -y install mysql-server mysql-client
set +x
############## password for root set as 'password'
############## to access mysql: $ mysql -u root -p    and then in prompt, type PWD i.e. password
#### or try: https://serversforhackers.com/video/installing-mysql-with-debconf
echo $'\n\nInstalling mysql (2b of 3)'
sleep $timer
set -x
sudo apt -y install libmysqlclient-dev
set +x
echo $'\n\nInstalling java (3 of 3)'
sleep $timer
set -x
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer
set +x

javaVersion="$(java -version 2>&1 >/dev/null | grep 'java version' | awk '{print $3}')"
echo $'\njavaVersion:' $"$javaVersion"


echo $'\n\nFinished installing python-dev,mysql and java\nNext.. zeromq, omniorb and finally tango\n'
cd
sleep $timer
echo "Fresh start.. any existing files/folders under /home/$USER/tangocs will be deleted"
if [ -d /home/$USER/tangocs ]; then
#    printf '%s\n' "Removing Lock (/home/$USER/tangocs)"
    rm -rf "/home/$USER/tangocs"
fi
# create folder, if it doesnt exist
mkdir /home/$USER/tangocs
cd /home/$USER/tangocs
echo $'\n\nTango folder created like: /home/username/tangocs\n'
sleep $timer



echo $'\n\nInstalling zeromq (1 of 3)\n'
sleep $timer
## zeromq: 4.0.8 exists,, also 4.1.5 , same date: july 3rd 2016
cd /home/$USER/Downloads
wget -c "https://archive.org/download/zeromq_$zmqVersion/zeromq-$zmqVersion.tar.gz"
cp zeromq-$zmqVersion.tar.gz /home/$USER/tangocs
cd /home/$USER/tangocs
#sudo wget -c "https://archive.org/download/zeromq_$zmqVersion/zeromq-$zmqVersion.tar.gz"
tar -xvzf zeromq-$zmqVersion.tar.gz 
cd /home/$USER/tangocs/zeromq-$zmqVersion/
echo $'\n\nConfiguring zeromq\n'
sleep $timer
set -x
./configure --prefix=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+ CFLAGS=-gstabs+ CXXFLAGS=-gstabs+
make
make install
set +x

echo $'\n\nInstalling OmniORB (2 of 3)\n'
#omniORB: 4.2.1-2 latest as of march 2017. downloaded 4.2.1 from sourceforge
sleep $timer
cd /home/$USER/Downloads
wget -c https://sourceforge.net/projects/omniorb/files/omniORB/omniORB-$omniorbVersion/omniORB-$omniorbVersion-2.tar.bz2
cp omniORB-$omniorbVersion-2.tar.bz2 /home/$USER/tangocs
# for regular versions, use: omniORB-$omniorbVersion.tar.bz2 instead of omniORB-$omniorbVersion-2.tar.bz2
#sudo wget -c http://ftp.esrf.fr/pub/cs/tango/Patches/dii_race.patch
cd /home/$USER/tangocs
tar jvxf omniORB-$omniorbVersion-2.tar.bz2
#sudo cp dii_race.patch /home/$USER/tangocs/omniORB-$omniorbVersion  # use this patch for omniORB4.2.1, current source file is 4.2.1a
cd omniORB-$omniorbVersion/
#patch -p1 < dii_race.patch
# file to patch: ./include/.../request.h    (OR)    ./src/lib...request.cc
echo $'\n\nConfiguring omniORB\n'
sleep $timer
set -x
./configure --prefix=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+ CFLAGS=-gstabs+ CXXFLAGS=-gstabs+ --enable-static
make
make install
set +x




echo $'\n\nInstalling Tango (3 of 3)\n'
# tango:
sleep $timer
# $tangoVersion for 9.2.5: file name is 9.2.5a, for others remove "a"  in the wget, tar and cd commands
cd /home/$USER/Downloads
echo $'Downloading tango source file'
wget  -c https://sourceforge.net/projects/tango-cs/files/tango-$tangoVersion"a".tar.gz/download

# if the above wget line fails, comment the above wget line and uncomment+use any of the following lines:
#wget -c --no-check-certificate -e robots=off -r https://sourceforge.net/projects/tango-cs/files/tango-$tangoVersion"a".tar.gz/download
#wget -o tango-$tangoVersion"a".tar.gz -c https://downloads.sourceforge.net/project/tango-cs/tango-9.2.5a.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Ftango-cs%2Ffiles%2Ftango-9.2.5a.tar.gz%2Fdownload&ts=1491050617&use_mirror=excellmedia 

cp download tango-$tangoVersion"a".tar.gz
cp tango-$tangoVersion"a".tar.gz /home/$USER/tangocs
cd /home/$USER/tangocs

tar -xvzf tango-$tangoVersion"a".tar.gz
cd tango-$tangoVersion"a"/
# export library to ubuntu library path
echo $'\nExporting library path'

LIBVALUE=$"/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+/lib"
LIBVALUE="$LIBVALUE:$LD_LIBRARY_PATH"
echo "export LD_LIBRARY_PATH=$LIBVALUE" >> ~/.bashrc


########## if Error: 2003: http://stackoverflow.com/questions/1673530/error-2003-hy000-cant-connect-to-mysql-server-on-127-0-0-1-111, then uncomment the following line and run the script
#sudo sed -i 's/bind-address/#  bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf

echo $'\n\nConfiguring tango\n'
sleep $timer
set -x
./configure --prefix=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+ --enable-static --with-omni=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+ --with-zmq=home/me/tango-$tangoVersion-gcc-$gccVersion-gstabs+ CFLAGS=-gstabs+ CXXFLAGS=-gstabs+ --with-mysql-admin=root --with-mysql-admin-passwd=password LDFLAGS="-L/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+/lib"
make
make install
set +x


clear

echo $'\n\nAdding bin folder to PATH, if not added earlier. \n'
BINPATH="/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+"
echo "PATH=$PATH:$BINPATH/bin" >> ~/.bashrc
export PATH="$PATH:$BINPATH/bin"
echo $'\nInstallation of Tango done\n'
sleep $timer


echo $'\nLet us verify it next..\n'
TANGO_INSTALL_DIR=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+



<<'SETENV'
#Now, you should be able to launch the DB server
TANGO_INSTALL_DIR=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+
DataBaseds 2 -ORBendPoint giop:tcp::10000  # fails
echo $'\nFailed. '
SETENV


echo $'\nLets setup environmental variables (tango_host, mysql_user, mysql_password) and try DataBaseds...\n'
HOST=$(hostname) 
TANGOHOST=$"$HOST:10000"
echo $TANGOHOST
echo "export TANGO_HOST=$TANGOHOST" >> ~/.bashrc
echo "export "MYSQL_USER=root"" >> ~/.bashrc
echo "export "MYSQL_PASSWORD=password"" >> ~/.bashrc
# above echo lines ensure that when a NEW terminal is opened, these env are valid. below export lines ensure that the CURRENT terminal reads these env.
export TANGO_HOST=$TANGOHOST
export MYSQL_USER=root
export MYSQL_PASSWORD=password

############exec bash # to source bash files that reflects ths new PATH and environ variables(incl tango bin)

#source $HOME/.bashrc

<<CHANGEMYCNF

# DIDNT NEED THIS..
sudo sed -i '/your_user/c\user=root' $TANGO_INSTALL_DIR/share/tango/db/my.cnf
sudo sed -i '/your_password/c\password=password' $TANGO_INSTALL_DIR/share/tango/db/my.cnf
DataBaseds 2 -ORBendPoint giop:tcp::10000  # works

CHANGEMYCNF


TANGO_INSTALL_DIR=/home/$USER/tangocs/tango-$tangoVersion-gcc-$gccVersion-gstabs+
echo $'\n\nLaunching DataBaseds\n'
sleep 2
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/DataBaseds 2 -ORBendPoint giop:tcp::10000; exec bash\""
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/DataBaseds 2 -ORBendPoint giop:tcp::10000  # works

timer_apps=5
echo $'\n\nLaunching Jive\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/jive 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/jive; exec bash\""

sleep 10

echo $'\n\nLaunching astor\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/astor 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/astor; exec bash\""
sleep 15

echo $'\n\nLaunching TangoTest\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/TangoTest test 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/TangoTest test; exec bash\""
sleep 10

echo $'\n\nLaunching tango device test'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/tg_devtest sys/tg_test/1
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/tg_devtest sys/tg_test/1; exec bash\""
sleep 5


<<TANGO
######
# check args for the following commands
#######


echo $'\n\nLaunching Starter\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/Starter 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/Starter tango/admin/$(hostname) ; exec bash\""------------------------------
sleep $timer_apps

echo $'\n\nLaunching POGO\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/pogo
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/pogo; exec bash\""
sleep 10

echo $'\n\nLaunching atkmoni\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/atkmoni 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/atkmoni; exec bash\""
sleep $timer_apps
echo $'\n\nLaunching atkpanel\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/atkpanel
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/atkpanel; exec bash\""
sleep 10
echo $'\n\nLaunching JDraw\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/jdraw 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/jdraw; exec bash\""
sleep 10

echo $'\n\nLaunching synoptic appli\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/synopticappli
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/synopticappli; exec bash\""
sleep $timer_apps


echo $'\n\nLaunching tango.............\n'
sleep $timer_apps 
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/tango 
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/tango; exec bash\"" -------------------------------------
sleep 15

echo $'\n\nLaunching tango access control\n'
sleep $timer_apps
#x-terminal-emulator -e $TANGO_INSTALL_DIR/bin/TangoAccessControl
gnome-terminal -e "bash -c \"reset;$TANGO_INSTALL_DIR/bin/TangoAccessControl; exec bash\""
sleep $timer_apps



###### NOTE:
# jive: error: connect to db fails (hostname, 10000) popup, set tango_host=localhost:10000     -works
# tangotest error: Can't build connection to TANGO database server, exiting, launch 'tangotest' after jive  -works
TANGO



echo $'\n\n\nHappy coding with Tango.. :)\n\n\n'
exec bash
