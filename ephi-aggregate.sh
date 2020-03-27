# #######################################################
# #
# # Ubuntu LTS 16.04 (ubuntu/xenial64)
# # 
# # Description: ephiPulse platform build script
# #
# # Notes: 
# #  - 
# #
# #######################################################


# ####################################################### ODK Aggregate
# 7) install ODK Aggregate
  # 7a) install guidelines
	 # https://github.com/opendatakit/aggregate/blob/v2.0.5/docs/build-the-installer-app.md
  # 7b) configuration guidelines
    # https://github.com/opendatakit/aggregate/blob/master/docs/aggregate-config.md

echo "------------ INSTALL GIT LFS ------------"
echo "------------ " 
# ####################################################### git lfs
# git lfs (large file system)
cd /tmp
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install -y git-lfs
git lfs install


echo "------------ CONFIGURE ODK AGGREGATE ------------"
echo "------------ " 
# ####################################################### java jre for gradle
# go to nginx folder
cd /home/ubuntu/nginx/www/
# clone ephi-reportPulse app
git clone https://github.com/pfitzpaddy/ephi-aggregate.git

# update property files
cp /home/ubuntu/nginx/www/ephi-aggregate/src/main/resources/jdbc.properties.example /home/ubuntu/nginx/www/ephi-aggregate/src/main/resources/jdbc.properties
cp /home/ubuntu/nginx/www/ephi-aggregate/src/main/resources/odk-settings.xml.example /home/ubuntu/nginx/www/ephi-aggregate/src/main/resources/odk-settings.xml
cp /home/ubuntu/nginx/www/ephi-aggregate/src/main/resources/security.properties.example /home/ubuntu/nginx/www/ephi-aggregate/src/main/resources/security.properties

# ephi installation
# update jdbc.properties
sudo sed -i "s|jdbc.resourceName=jdbc/aggregate|jdbc.resourceName=jdbc/ephi|" /home/ubuntu/data/aggregate-2.0.5/src/main/resources/jdbc.properties
sudo sed -i "s|jdbc.url=jdbc:postgresql://127.0.0.1/aggregate?autoDeserialize=true|jdbc.url=jdbc:postgresql://127.0.0.1/ephi?autoDeserialize=true|" /home/ubuntu/data/aggregate-2.0.5/src/main/resources/jdbc.properties
sudo sed -i "s|jdbc.username=aggregate|jdbc.username=ephiadmin|" /home/ubuntu/data/aggregate-2.0.5/src/main/resources/jdbc.properties
sudo sed -i "s|jdbc.password=aggregate|jdbc.password=ephiadmin|" /home/ubuntu/data/aggregate-2.0.5/src/main/resources/jdbc.properties
sudo sed -i "s|jdbc.schema=aggregate|jdbc.schema=phem|" /home/ubuntu/data/aggregate-2.0.5/src/main/resources/jdbc.properties


echo "------------ INSTALL GRADLE ------------"
echo "------------ " 
# ####################################################### Gradle
# gradle v3.x.x (install after JAVA)
  # gradle 5.x+ does not support "getClassesDir"
  # https://github.com/steffenschaefer/gwt-gradle-plugin/issues/118
cd /tmp
# wget gradle repo (https://gradle.org/releases/)
wget https://services.gradle.org/distributions/gradle-4.8.1-bin.zip
# unzip
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-4.8.1-bin.zip
# clean up
sudo rm gradle-4.8.1-bin.zip
export PATH=$PATH:/opt/gradle/gradle-4.8.1/bin
gradle -v


echo "------------ INSTALL JRE ------------"
echo "------------ " 
# ####################################################### java jre for gradle
# jdk
sudo apt install -y openjdk-8-jdk-headless


echo "------------ INSTALL installbuilder-18 ------------"
echo "------------ " 
# ####################################################### installbuilder-18
# install installbuilder-18 ( https://clients.bitrock.com/installbuilder/docs/installbuilder-userguide/ar01s02.html#installation )
cd /tmp
# 145 MB download
wget https://installbuilder.com/installbuilder-enterprise-18.10.0-linux-x64-installer.run
chmod +x installbuilder-enterprise-18.10.0-linux-x64-installer.run
sudo ./installbuilder-enterprise-18.10.0-linux-x64-installer.run
  # 13
  # y
  # y
  # n


echo "------------ COMPILE ODK AGGREGATE ------------"
echo "------------ " 
# ####################################################### java jre for gradle
# gradle installation properties
cp /home/ubuntu/nginx/www/ephi-aggregate/gradle.properties.example /home/ubuntu/nginx/www/ephi-aggregate/gradle.properties
sudo sed -i "s|#packerZip=https://releases.hashicorp.com/packer/1.3.4/packer_1.3.4_linux_amd64.zip|packerZip=https://releases.hashicorp.com/packer/1.3.4/packer_1.3.4_linux_amd64.zip|" /home/ubuntu/nginx/www/ephi-aggregate/gradle.properties
sudo sed -i "s|#installBuilderHome=/opt/installbuilder-18.10.0|installBuilderHome=/opt/installbuilder-20.2.0|" /home/ubuntu/nginx/www/ephi-aggregate/gradle.properties
# cd ephi-aggregate
cd /home/ubuntu/nginx/www/ephi-aggregate
# gradle localhost run appRunWar (./gradlew appRunWar)
# grable compile ODK Aggregate WAR file
./gradlew clean build installerBuild -xtest -PwarMode=installer
# unzip ubuntu
# cd /home/ubuntu/nginx/www/ephi-aggregate/build/installers
# sudo unzip /home/ubuntu/nginx/www/ephi-aggregate/build/installers/ODK-Aggregate-v2.0.5-dirty-Linux-x64.run.zip 
# chmod +x /home/ubuntu/nginx/www/ephi-aggregate/build/installers/ODK-Aggregate-v2.0.5-dirty-Linux-x64.run
# ./ODK-Aggregate-v2.0.5-dirty-Linux-x64.run
sudo mv /home/ubuntu/nginx/www/ephi-aggregate/build/installer/files/ODKAggregate.war /var/lib/tomcat8/webapps
sudo mv /home/ubuntu/nginx/www/ephi-aggregate/war/ODK\ Aggregate/ODKAggregate.war /var/lib/tomcat8/webapps/
sudo systemctl restart tomcat8


# echo "------------ MV TO TOMCAT8 ------------"
# echo "------------ " 
# # ####################################################### java jre for gradle
# # mv WAR file

# # restart tomcat8
# sudo systemctl restart tomcat8
