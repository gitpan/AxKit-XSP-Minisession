#!perl
# $Id: SMOKE.PL 320 2005-03-05 18:07:22Z claco $
use strict;
use warnings FATAL => 'all';
use lib qw(lib);

use Apache::TestSmoke ();

Apache::TestSmoke->new(@ARGV)->run;
