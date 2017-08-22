#!/usr/bin/env bats

setup () {
    teardown
    mkdir -p .testcerts
	echo 1000 > .testcerts/serial
	openssl genrsa -out .testcerts/root.key 4096
	openssl req -config tests/openssl.cnf -extensions v3_ca -outform PEM -new -x509 -days 7 -key .testcerts/root.key -nodes -out .testcerts/root.crt -subj /C=US/ST=State/L=City/O=RootCA/OU=Unit/CN=localhost/emailAddress=none@nowhere.com
	openssl genrsa -out .testcerts/intermediate1.key 4096
	openssl req -config tests/openssl.cnf -extensions v3_ca -new -key .testcerts/intermediate1.key -out .testcerts/intermediate1.csr -subj /C=US/ST=State/L=City/O=FirstIntermediate/OU=Unit/CN=localhost/emailAddress=none@nowhere.com
	openssl x509 -extfile tests/openssl.cnf -extensions v3_ca -outform PEM -req -days 7 -in .testcerts/intermediate1.csr -out .testcerts/intermediate1.crt -CAkey .testcerts/root.key -CA .testcerts/root.crt -CAserial .testcerts/serial
	openssl genrsa -out .testcerts/intermediate2.key 4096
	openssl req -config tests/openssl.cnf -extensions v3_ca -new -key .testcerts/intermediate2.key -out .testcerts/intermediate2.csr -subj /C=US/ST=State/L=City/O=SecondIntermediate/OU=Unit/CN=localhost/emailAddress=none@nowhere.com
	openssl x509 -extfile tests/openssl.cnf -extensions v3_ca  -outform PEM -req -days 7 -in .testcerts/intermediate2.csr -out .testcerts/intermediate2.crt -CAkey .testcerts/intermediate1.key -CA .testcerts/intermediate1.crt -CAserial .testcerts/serial
	openssl genrsa -out .testcerts/server.key 4096
	openssl req -new -key .testcerts/server.key -out .testcerts/server.csr -subj /C=US/ST=State/L=City/O=Server/OU=Unit/CN=localhost/emailAddress=none@nowhere.com
	openssl x509 -outform PEM -req -days 7 -in .testcerts/server.csr -out .testcerts/server.crt -CAkey .testcerts/intermediate2.key -CA .testcerts/intermediate2.crt -CAserial .testcerts/serial
	cat .testcerts/intermediate1.crt .testcerts/intermediate2.crt > .testcerts/intermediates.crt
}

teardown () {
    kill "$(cat .server.pid)" || true
    git clean -fdX
}

server_test () {
	openssl s_server -cert .testcerts/bundle.crt -key .testcerts/server.key -quiet -www -no_dhe &
    echo "$!" > .server.pid
	run curl --fail --cacert .testcerts/root.crt --write-out '%{ssl_verify_result}' --silent --output /dev/null https://localhost:4433
    [ "$output" = "0" ]
    [ "$status" = "0" ]
}

@test "Source and run" {
    env -i sh -ic '. ./bundle_certs && bundle_certs .testcerts/* > .testcerts/bundle.crt'
    server_test
}

@test "Run" {
    ./bundle_certs .testcerts/* > .testcerts/bundle.crt
    server_test
}
