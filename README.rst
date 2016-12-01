bundle-certs
############

.. image:: https://travis-ci.org/adarnimrod/bundle_certs.svg?branch=master
    :target: https://travis-ci.org/adarnimrod/bundle_certs

A shell script to bundle SSL certificates in the correct order. The use case
envisioned is programmatically handling SSL certificate renewal.

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

The outputted bundle is WITHOUT the root (CA) certificate.

Shell functions
---------------

- subject_hash: Returns OpenSSL's hash of the cert's subject.
- issuer_hash: Returns OpenSSL's hash of the cert's issuer.
- find_root_cert: Return the filename of the (first) root (self-signed)
  certificate of the filenames passed as parameters.
- find_cert_by_issuer_hash: Gets a hash and a list of filenames, returns the
  filename of the certificate with that issuer hash. Ignores self-signed (root
  CA) certificates.
- unbudle_cert: Gets a filename, creates a directory named :code:`certs` which
  contains all of the individual certs in the file (the files are named by their
  subject hash).
- bundle_certs: See Usage section above.

Development
-----------

For testing run :code:`make test`. For cleaning temporary files run :code:`git
clean -fdx`. You can use `pre-commit <http://pre-commit.com/>`_ to have the test
(which is quite quick) run on every commit to ensure quality code.

License
-------

This software is licensed under the MIT license (see the :code:`LICENSE.txt`
file).

Author Information
------------------

Nimrod Adar, `contact me <nimrod@shore.co.il>`_ or visit my `website
<https://www.shore.co.il/>`_. Patches are welcome via `git send-email
<http://git-scm.com/book/en/v2/Git-Commands-Email>`_. The repository is located
at: https://www.shore.co.il/cgit/.
