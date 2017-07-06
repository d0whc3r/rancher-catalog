#!/bin/bash
caname="myca"
fileconf="${caname}.conf"
dircerts="certs"
certca="ca.cert"
keyca="privkey.pem"
domain="yourdoamin.tld"
maxconsul=3

rm -rf serial certindex ${fileconf} cert* *.pem *.old ${dircerts}
mkdir -p ${dircerts}

echo "000a" > serial
touch certindex

cat << EOF > ${fileconf}
[ ca ]
default_ca = ${caname}

[ ${caname} ]
unique_subject = no
new_certs_dir = .
certificate = ${dircerts}/${certca}
database = certindex
private_key = ${dircerts}/${keyca}
serial = serial
default_days = 3650
default_md = sha1
policy = ${caname}_policy
x509_extensions = ${caname}_extensions

[ ${caname}_policy ]
commonName = supplied
stateOrProvinceName = supplied
countryName = supplied
emailAddress = optional
organizationName = supplied
organizationalUnitName = optional

[ ${caname}_extensions ]
basicConstraints = CA:false
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth,clientAuth

EOF

openssl req -newkey rsa:2048 -days 3650 -x509 -nodes -out ${dircerts}/${certca} -keyout ${dircerts}/${keyca}

for i in `seq 1 ${maxconsul}`; do
  openssl req -newkey rsa:1024 -nodes -out ${dircerts}/consul${i}.csr -keyout ${dircerts}/consul${i}.key
  openssl ca -batch -config ${fileconf} -notext -in ${dircerts}/consul${i}.csr -out ${dircerts}/consul${i}.cert
done

echo "[+] CA Cert:"
cat ${dircerts}/${certca}

for i in `seq 1 ${maxconsul}`; do
  echo "[+] Consul${i} Cert:"
  cat ${dircerts}/consul${i}.cert
done

for i in `seq 1 ${maxconsul}`; do
  echo "[+] Consul${i} Key:"
  cat ${dircerts}/consul${i}.key
done

echo "[+] Gossip:"
docker run --rm consul keygen
