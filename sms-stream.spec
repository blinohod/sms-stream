%define streamdir /opt/sms-stream

%define _perl_lib_path %streamdir/lib

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
%setup -n %name-%version

%build

%install
%makeinstall_std

%pre

%files
%streamdir
#%%doc README samples
#%%dir %%attr(0755,root,root)  %%_sysconfdir/NetSDS/admin/mgr
#%%config(noreplace) %%attr(0755,root,root) %%_sysconfdir/rc.d/init.d/kannel.send-*

%changelog
* Tue Jul 17 2012 Michael Bochkaryov <misha@altlinux.ru> 2.0-alt1
- Initial build of SMS Stream 2.0



