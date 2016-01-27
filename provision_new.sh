#!/bin/bash
while [[ $# > 1 ]]
do
key="$1"

case $key in

	# variables
    --configbucket)
    configbucket="$2"
    shift # past argument
    ;;
    --imagesbucket)
    imagesbucket="$2"
    shift # past argument
    ;;
    --themesbucket)
    themesbucket="$2"
    shift # past argument
    ;;
    --uploadsbucket)
    uploadsbucket="$2"
    shift # past argument
    ;;
    --dbname)
    dbname="$2"
    shift # past argument
    ;;
    --tableprefix)
    tableprefix="$2"
    shift # past argument
    ;;

	# create_tables.py
    --dbhost)
    dbhost="$2"
    shift # past argument
    ;;
    --dbuser)
    dbuser="$2"
    shift # past argument
    ;;
    --dbpass)
    dbpass="$2"
    shift # past argument
    ;;
    --dbengine)
    dbengine="$2"
    shift # past argument
    ;;
    --dbname)
    dbname="$2"
    shift # past argument
    ;;
    --tableprefix)
    tableprefix="$2"
    shift # past argument
    ;;

    # configure_board.py
    --bbname)
    bbname="$2"
    shift # past argument
    ;;
    --bburl)
    bburl="$2"
    shift # past argument
    ;;
    --websitename)
    websitename="$2"
    shift # past argument
    ;;
    --websiteurl)
    websiteurl="$2"
    shift # past argument
    ;;
    --cookiedomain)
    cookiedomain="$2"
    shift # past argument
    ;;
    --cookiepath)
    cookiepath="$2"
    shift # past argument
    ;;
    --contactemail)
    contactemail="$2"
    shift # past argument
    ;;
    --pin)
    pin="$2"
    shift # past argument
    ;;
    --adminuser)
    adminuser="$2"
    shift # past argument
    ;;
    --adminpass)
    adminpass="$2"
    shift # past argument
    ;;
    --adminemail)
    adminemail="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

# Install web and dev dependencies
yum install -y httpd php mysql-server php-mysqlnd php-pear php-pecl-memcache php-gd
service httpd start
chkconfig httpd on

cd /var/www/html
echo '<?php  echo "<i>The server is healthy @ " . date("Y-m-d h:i:s a") . "</i><br>"; ?>' > health.php

# Get and install myBB.
wget --content-disposition http://resources.mybb.com/downloads/mybb_1806.zip  -O mybb.zip
unzip mybb.zip "Upload/*"
mv Upload/* .
rm -Rf Upload mybb.zip
mv inc/config.default.php inc/config.php
chmod -R 0777 cache uploads inc/settings.php inc/config.php

# Install S3SF.
cd ~
yum install -y gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel libxml2-devel mailcap automake openssl-devel
git clone https://github.com/s3fs-fuse/s3fs-fuse
cd s3fs-fuse/
./autogen.sh
./configure --prefix=/usr --with-openssl
make
sudo make install

# Set uploads to S3
mkdir /var/www/html/uploads-temp
mv /var/www/html/uploads/* /var/www/html/uploads-temp/
s3fs $uploadsbucket /var/www/html/uploads -o iam_role=default-role,rw,nosuid,nodev,allow_other,stat_cache_expire=1
mv /var/www/html/uploads-temp/* /var/www/html/uploads/
rm -rf /var/www/html/uploads-temp/

# Set themes to S3
mkdir /var/www/html/cache/themes-temp
mv /var/www/html/cache/themes/* /var/www/html/cache/themes-temp/
s3fs $themesbucket /var/www/html/cache/themes -o iam_role=default-role,rw,nosuid,nodev,allow_other,stat_cache_expire=1
mv /var/www/html/cache/themes-temp/* /var/www/html/cache/themes/
rm -rf /var/www/html/cache/themes-temp/

# Set images to S3
mkdir /var/www/html/images-temp
mv /var/www/html/images/* /var/www/html/images-temp/
s3fs $imagesbucket /var/www/html/images -o iam_role=default-role,rw,nosuid,nodev,allow_other,stat_cache_expire=1
mv /var/www/html/images-temp/* /var/www/html/images/
rm -rf /var/www/html/images-temp/

python /var/myBBDeployment/create_tables.py --dbhost $dbhost --dbengine mysqli --dbuser $dbuser --dbpass $dbpass --dbname $dbname --tableprefix $tableprefix
python /var/myBBDeployment/configure_board.py --bbname $bbname --bburl $bburl --websitename $websitename --websiteurl $websiteurl --cookiedomain $cookiedomain --cookiepath $cookiepath --contactemail $contactemail --pin $pin --adminuser $adminuser --adminpass $adminpass --adminemail $adminemail

# Complete web config.
groupadd www
usermod -a -G www ec2-user
usermod -a -G www apache
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
rm -Rf install

# Copy config from S3.
aws s3 cp /var/www/html/inc/config.php s3://$configbucket/config.php
cd /var/www/
zip -r mybb.zip html -x "html/images/*" -x "html/uploads/*" -x "html/cache/themes/*"
aws s3 cp mybb.zip s3://$configbucket/mybb.zip