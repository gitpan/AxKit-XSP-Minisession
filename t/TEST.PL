#!perl
# $Id: TEST.PL 110 2005-02-03 23:54:06Z claco $

use strict;
use warnings FATAL => 'all';
use lib qw(lib);

use Apache::TestRunPerl ();

Apache::TestRunPerl->new->run(@ARGV);
