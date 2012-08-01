%define streamdir /opt/sms-stream
%define _initdir /etc/rc.d/init.d
%define _logdir /var/log

%define _perl_lib_path %streamdir/lib

Name: sms-stream
Version: 2.0
Release: el6.1

Summary: SMS Stream bulk SMS gateway platform

License: GPL

Group: Networking/Other
Url: http://www.netstyle.com.ua/

Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source0: %name-%version.tar

BuildRequires: make
BuildRequires: perl-CGI perl-Class-Accessor-Class perl-Config-General perl-DBI perl-FCGI perl-Unix-Syslog perl-IPC-ShareLite

Requires: kannel
Requires: httpd mod_fastcgi
Requires: postgresql-libs 
Requires: perl-CGI perl-Class-Accessor-Class perl-Config-General perl-DBI perl-FCGI perl-Unix-Syslog perl-IPC-ShareLite

%description
SMS Stream bulk SMS gateway platform

%prep
%setup -n %name-%version

%build

%install
%make_install
mkdir -p %buildroot/etc/httpd/conf.d
install -m 750 setup/centos6/apache.conf %buildroot/etc/httpd/conf.d/sms-stream.conf

%pre

%files
%dir %attr(0755,root,root) %streamdir
%dir %attr(0755,root,root) %streamdir/etc
%config(noreplace) %attr(0755,root,root) %streamdir/etc/sms-stream.conf
%streamdir/sbin
%streamdir/lib
%streamdir/web
%streamdir/setup
%config(noreplace) %attr(0755,root,root) /etc/httpd/conf.d/sms-stream.conf
#%%doc README samples

%changelog
* Wed Aug 1 2012 Michael Bochkaryov <misha@altlinux.ru> 2.0-el6.1
- Configuration is packaged correctly
- Run-time requirements added

* Tue Jul 17 2012 Michael Bochkaryov <misha@altlinux.ru> 2.0-alt1
- Initial build of SMS Stream 2.0



