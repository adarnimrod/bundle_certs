#!/usr/bin/env bats

setup () {
    teardown
    mkdir -p .testcerts
	openssl genrsa -out .testcerts/root.key 4096
	openssl req -extensions v3_ca -outform PEM -new -x509 -days 7 -key .testcerts/root.key -nodes -out .testcerts/root.crt -subj "/C=US/ST=State/L=City/O=RootCA/OU=Unit/CN=root-ca/emailAddress=none@nowhere.com/"

	openssl genrsa -out .testcerts/intermediate1.key 4096
	openssl req -extensions v3_ca -new -key .testcerts/intermediate1.key -out .testcerts/intermediate1.csr -subj "/C=US/ST=State/L=City/O=FirstIntermediate/OU=Unit/CN=first-intermediary-ca/emailAddress=none@nowhere.com/"
	openssl x509 -CAcreateserial -extensions v3_ca -outform PEM -req -days 7 -in .testcerts/intermediate1.csr -out .testcerts/intermediate1.crt -CAkey .testcerts/root.key -CA .testcerts/root.crt

	openssl genrsa -out .testcerts/intermediate2.key 4096
	openssl req -extensions v3_ca -new -key .testcerts/intermediate2.key -out .testcerts/intermediate2.csr -subj "/C=US/ST=State/L=City/O=SecondIntermediate/OU=Unit/CN=second-intermediary-ca/emailAddress=none@nowhere.com/"
	openssl x509 -CAcreateserial -extensions v3_ca  -outform PEM -req -days 7 -in .testcerts/intermediate2.csr -out .testcerts/intermediate2.crt -CAkey .testcerts/intermediate1.key -CA .testcerts/intermediate1.crt

	openssl genrsa -out .testcerts/server.key 4096
	openssl req -new -key .testcerts/server.key -out .testcerts/server.csr -subj "/C=US/ST=State/L=City/O=Server/OU=Unit/CN=localhost/emailAddress=none@nowhere.com/"
	openssl x509 -CAcreateserial -outform PEM -req -days 7 -in .testcerts/server.csr -out .testcerts/server.crt -CAkey .testcerts/intermediate2.key -CA .testcerts/intermediate2.crt

	cat .testcerts/intermediate1.crt .testcerts/intermediate2.crt > .testcerts/intermediates.crt
}

teardown () {
    git clean -fdX
}

server_test () {
    cat .testcerts/bundle.crt | openssl verify -CAfile .testcerts/root.crt
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
