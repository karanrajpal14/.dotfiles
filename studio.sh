apt install software-properties-common python-software-properties -y
add-apt-repository ppa:webupd8team/java
dpkg --configure -a
apt-get update
apt-get install java-common oracle-java8-installer -y
# apt-get install oracle-java8-set-default -y
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
apt-add-repository ppa:maarten-fonville/android-studio -y
dpkg --configure -a
apt update
apt-get install android-studio -y