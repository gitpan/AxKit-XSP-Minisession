# $Id: 002_pod.t,v 1.4 2004/11/25 01:24:26 claco Exp $
use Test::More;

eval 'use Test::Pod 1.00';
plan skip_all => 'Test::Pod 1.00 required for testing pod syntax' if $@;

all_pod_files_ok();
