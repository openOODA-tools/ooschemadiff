Name:           ooschemadiff
Version:        0.1.0
Release:        1%{?dist}
Summary:        Database and OpenAPI schema migration differ ensuring backwards compatibility.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/ooschemadiff
Source0:        ooschemadiff-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
ooschemadiff is a sovereign, capability-bounded SCHEMA DIFFER written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/ooschemadiff
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/ooschemadiff-uninstall

%files
/usr/bin/ooschemadiff
/usr/bin/ooschemadiff-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
