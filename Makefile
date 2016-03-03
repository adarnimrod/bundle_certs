.PHONY: test clean lint

lint:
	/bin/sh -en bundle_certs

clean:
	if [ -f .server.pid ] && [ -d "/proc/$$(cat .server.pid)" ]; then kill "$$(cat .server.pid)"; fi
	rm -rf .testcerts certs .server.pid

.testcerts:
	mkdir -p .testcerts

.testcerts/serial: .testcerts
	echo 1000 > .testcerts/serial

.testcerts/root.key: .testcerts
	openssl genrsa -out .testcerts/root.key 4096

.testcerts/root.crt: .testcerts/root.key
	openssl req -new -x509 -days 7 -key .testcerts/root.key -nodes -out .testcerts/root.crt -subj /C=US/ST=State/L=City/O=RootCA/OU=Unit/CN=localhost/emailAddress=none@nowhere.com

.testcerts/intermediate1.key: .testcerts
	openssl genrsa -out .testcerts/intermediate1.key 4096

.testcerts/intermediate1.csr: .testcerts/intermediate1.key
	openssl req -new -key .testcerts/intermediate1.key -out .testcerts/intermediate1.csr -subj /C=US/ST=State/L=City/O=FirstIntermediate/OU=Unit/CN=localhost/emailAddress=none@nowhere.com

.testcerts/intermediate1.crt: .testcerts/intermediate1.csr .testcerts/root.key .testcerts/root.crt .testcerts/serial
	openssl x509 -req -days 7 -in .testcerts/intermediate1.csr -out .testcerts/intermediate1.crt -CAkey .testcerts/root.key -CA .testcerts/root.crt -CAserial .testcerts/serial

.testcerts/intermediate2.key: .testcerts
	openssl genrsa -out .testcerts/intermediate2.key 4096

.testcerts/intermediate2.csr: .testcerts/intermediate2.key
	openssl req -new -key .testcerts/intermediate2.key -out .testcerts/intermediate2.csr -subj /C=US/ST=State/L=City/O=SecondIntermediate/OU=Unit/CN=localhost/emailAddress=none@nowhere.com

.testcerts/intermediate2.crt: .testcerts/intermediate2.csr .testcerts/intermediate1.key .testcerts/serial .testcerts/intermediate1.crt
	openssl x509 -req -days 7 -in .testcerts/intermediate2.csr -out .testcerts/intermediate2.crt -CAkey .testcerts/intermediate1.key -CA .testcerts/intermediate1.crt -CAserial .testcerts/serial

.testcerts/server.key: .testcerts
	openssl genrsa -out .testcerts/server.key 4096

.testcerts/server.csr: .testcerts/server.key
	openssl req -new -key .testcerts/server.key -out .testcerts/server.csr -subj /C=US/ST=State/L=City/O=Server/OU=Unit/CN=localhost/emailAddress=none@nowhere.com
	
.testcerts/server.crt: .testcerts/intermediate2.key .testcerts/server.csr .testcerts/serial .testcerts/intermediate2.crt
	openssl x509 -req -days 7 -in .testcerts/server.csr -out .testcerts/server.crt -CAkey .testcerts/intermediate2.key -CA .testcerts/intermediate2.crt -CAserial .testcerts/serial
	
.testcerts/intermediates.crt: .testcerts/intermediate1.crt .testcerts/intermediate2.crt
	cat .testcerts/intermediate1.crt .testcerts/intermediate2.crt > .testcerts/intermediates.crt

.testcerts/bundle.crt: .testcerts/intermediates.crt .testcerts/server.crt
	./bundle_certs .testcerts/* > .testcerts/bundle.crt

test: lint .testcerts/bundle.crt .testcerts/root.crt .testcerts/server.key
	openssl s_server -cert .testcerts/bundle.crt -key .testcerts/server.key -quiet -www -no_dhe & echo "$$!" > .server.pid
	test "$$(curl --fail --cacert .testcerts/root.crt --write-out '%{ssl_verify_result}' --silent --output /dev/null https://localhost:4433)" = "0"
	if [ -f .server.pid ] && [ -d "/proc/$$(cat .server.pid)" ]; then kill "$$(cat .server.pid)"; fi
	rm -f .server.pid



