dir = gencerts
ncdir = certs
confdir = certconf

root: cat = root
ca: cat = ca
server: cat = server


install:
	pip install --upgrade pip
	pip install -r requirements.txt

prepare:
	rm -rf ${ncdir} && rm -rf ${dir}
	mkdir ${ncdir} && mkdir ${dir}
	cp ${confdir}/index.txt ${dir}/index.txt

root:
	mkdir -p ${ncdir}/${cat}
	mkdir -p ${dir}/${cat}
	echo "12345678901234567890" > ${dir}/${cat}/${cat}.crt.srl
	openssl ecparam -out ${dir}/${cat}/${cat}.key -name secp384r1 -genkey
	openssl req -new -out ${dir}/${cat}/${cat}.csr -key ${dir}/${cat}/${cat}.key -config ${confdir}/root.conf
	openssl x509 -req -in ${dir}/${cat}/${cat}.csr -days 30 -signkey ${dir}/${cat}/${cat}.key -out ${dir}/${cat}/${cat}.crt -extensions v3_ca -extfile ${confdir}/root.conf -sha256

ca:
	mkdir -p ${ncdir}/${cat}
	mkdir -p ${dir}/${cat}
	echo "09876543210987654321" > ${dir}/${cat}/${cat}.crt.srl
	openssl ecparam -out ${dir}/${cat}/${cat}.key -name secp384r1 -genkey
	openssl req -new -out ${dir}/${cat}/${cat}.csr -key ${dir}/${cat}/${cat}.key -config ${confdir}/ca.conf
	openssl ca -batch -in ${dir}/${cat}/${cat}.csr -days 30 -out ${dir}/${cat}/${cat}.crt -config ${confdir}/root.conf -extensions v3_ca

server:
	mkdir -p ${dir}/${cat}
	openssl ecparam -out ${dir}/${cat}/${cat}.key -name secp384r1 -genkey
	openssl req -new -out ${dir}/${cat}/${cat}.csr -key ${dir}/${cat}/${cat}.key -config ${confdir}/server.conf
	openssl ca -batch -in ${dir}/${cat}/${cat}.csr -days 30 -out ${dir}/${cat}/${cat}.crt -config ${confdir}/ca.conf -extensions server_cert
	openssl x509 -in ${dir}/${cat}/${cat}.crt -out ${dir}/${cat}/${cat}.pem
	cp ${dir}/${cat}/${cat}.key ${dir}/${cat}/${cat}_private_key.pem

start:
	python src/app.py


all: install cleanup root ca server start