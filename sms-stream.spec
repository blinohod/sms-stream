%define homedir /opt/sms-stream

Name: sms-stream
Version: 2.0
Release: alt1

Summary: SMS Stream bulk SMS gateway platform

License: GPL

Group: Networking/Other
Url: http://www.netstyle.com.ua/

Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source0: %name-%version.tar

BuildRequires: make

BuildRequires: perl-CGI perl-Class-Accessor-Class perl-Config-General perl-DBI perl-Encode perl-FCGI perl-Unix-Syslog

%description
SMS Stream bulk SMS gateway platform

%prep
%setup -n %name

%build

%install
make install

%pre

%files
%homedir
#%doc README samples

%dir %attr(0755,root,root)  %_sysconfdir/NetSDS/admin/mgr
%config(noreplace) %attr(0644,root,apache) %_sysconfdir/NetSDS/admin/report/*
%config(noreplace) %attr(0755,root,root) %_sysconfdir/rc.d/init.d/kannel.send-*

%changelog
- 


