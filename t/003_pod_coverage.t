# $Id: 003_pod_coverage.t 110 2005-02-03 23:54:06Z claco $
use Test::More;

eval 'use Test::Pod::Coverage 1.04';
plan skip_all =>
    'Test::Pod::Coverage 1.04 required for testing pod coverage' if $@;

plan tests => 1;

my $trustme = { also_private => [qr/^(parse_.*|start_document)$/] };
pod_coverage_ok( 'AxKit::XSP::Minisession', $trustme );
