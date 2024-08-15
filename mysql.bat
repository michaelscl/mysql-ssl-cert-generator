@echo off

:: https://stackoverflow.com/questions/36920558/is-there-anyway-to-specify-basicconstraints-for-openssl-cert-via-command-line

SET OPENSSL_CONF=.\openssl.cnf
SET SSL=d:\util\openssl64\openssl.exe
SET PREFIX=mysql
SET CERTS=server client

echo Create CA certificate
echo ---------------------
::%SSL% genrsa 2048 > %PREFIX%-ca-key.pem
::%SSL% req -x509 -new -subj "/CN=MySQL CA" -nodes -days 72000 -key %PREFIX%-ca-key.pem -out %PREFIX%-ca.pem
echo ---------------------------------------------------------


for %%N in (%CERTS%) do (
	echo Create %%N certificate, remove passphrase, and sign it
	echo ---------------------------------------------------------
	%SSL% req -x509 -subj "/CN=10.10.203.20" -newkey rsa:2048 -days 72000 -nodes -keyout %PREFIX%-%%N-key.pem -out %PREFIX%-%%N-req.pem
	%SSL% rsa -in %PREFIX%-%%N-key.pem -out %PREFIX%-%%N-key.pem
	%SSL% x509 -in %PREFIX%-%%N-req.pem -days 3600 -CA %PREFIX%-ca.pem -CAkey %PREFIX%-ca-key.pem -out %PREFIX%-%%N-cert.pem
	echo ---------------------------------------------------------
	echo verify %%N cert
	%SSL% verify -CAfile %PREFIX%-ca.pem %PREFIX%-%%N-cert.pem
)

pause

