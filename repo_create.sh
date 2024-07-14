
#!/bin/bash


yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano lynx
mkdir rpm && cd rpm
yumdownloader --source nginx
rpm -Uvh nginx*.src.rpm
yum-builddep -y nginx
cd /root
git clone --recurse-submodules -j8 \https://github.com/google/ngx_brotli
cd ngx_brotli/deps/brotli
mkdir out && cd out
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
cmake --build . --config Release -j 2 --target brotlienc
cd ../../../..
cd ~/rpmbuild/SPECS/
sed -i '312a\    --add-module=/root/ngx_brotli \\' /root/rpmbuild/SPECS/nginx.spec
rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
ll /root/rpmbuild/RPMS/x86_64
cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/
cd ~/rpmbuild/RPMS/x86_64
yum -y localinstall *.rpm
systemctl start nginx
systemctl enable nginx
systemctl status nginx
mkdir /usr/share/nginx/html/repo
cp ~/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/
sed -i '46a\        index  index.html index.htm;\' /etc/nginx/nginx.conf
sed -i '47a\        autoindex on;\' /etc/nginx/nginx.conf
sed -i '48a\      \' /etc/nginx/nginx.conf
nginx -t
nginx -s reload
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo/
gpgcheck=0
enabled=1
EOF
yum repolist enabled | grep otus
cd /usr/share/nginx/html/repo/
wget https://repo.percona.com/yum/percona-release-latest.noarch.rpm
createrepo /usr/share/nginx/html/repo/
yum makecache
yum install -y percona-release.noarch
