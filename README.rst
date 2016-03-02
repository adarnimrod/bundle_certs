bundle-certs
############

A shell script to bundle SSL certificates in the correct order.

Installation
------------

This script can be used in 2 ways. The 1st is copying to
:code:`/usr/local/bin/bundle_certs`, marking as executable and calling the
script. The 2nd is copying the file to somewhere under you home directory and
sourcing it in your shell's rc file (like .bashrc, .kshrc etc.).

Usage
-----

Call the script/ function with the list of certificates you want to order, for
example:

.. code:: shell

    bundle_certs *.crt
