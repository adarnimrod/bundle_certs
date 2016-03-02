bundle-certs
############

A shell script to bundle SSL certificates in the correct order.

Installation
------------

This script can be used in 2 ways. The 1st is copying to
:code:`/usr/local/bin/bundle_certs`, marking as executable and calling the
script. The 2nd is copying the file to somewhere under you home directory and
sourcing it in your shell's rc file (like .bashrc, .kshrc etc.). With the 2nd
way you gain a few shell function for handling SSL certificates (listed below).


Requirements
------------

For regular use:
- A POSIX compatible shell.
- OpenSSL.
- AWK.

For testing/ development purposes, all of the above, plus:
- Make.
- Curl.

Usage
-----

Call the script/ function with the list of certificates you want to order, for
example:

.. code:: shell

    bundle_certs *.crt > bundle.crt

The outputed bundle is WITHOUT the root (CA) certificate.

Shell functions
---------------

- subject_hash: Returns OpenSSL's hash of the cert's subject.
- issuer_hash: Returns OpenSSL's hash of the cert's issuer.
- find_root_cert: Return the filename of the (first) root (self-signed)
  certificate of the filenames passed as parameters.
- find_cert_by_hash: Gets a hash and a list of filenames, returns the
  filename of the certificate with that subject hash.
- unbudle_cert: Gets a filename, creates a directory named :code:`certs` which
  contains all of the individual certs in the file (the files are named by their
  subject hash).
- bundle_certs: See Usage section above.


Testing
-------

Simply run:

.. code:: shell

    make test
