#!perl
# $Id: TEST.PL,v 1.2 2004/11/24 03:11:18 claco Exp $

use strict;
use warnings FATAL => 'all';
use lib qw(lib);

use Apache::TestRunPerl ();

Apache::TestRunPerl->new->run(@ARGV);
