# $Id: Makefile.PL 321 2005-03-05 18:09:47Z claco $
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Spec::Functions;
use File::Path;

my $sessiondir = catfile('t', 'htdocs', 'session');
my $sessionlockdir = catfile('t', 'htdocs', 'sessionlock');

eval 'use Apache::Test 1.16';
if (!$@) {
    require Apache::TestMM;
    Apache::TestMM->import(qw(test clean));

    ## for whatever reason, use AxKit causes issues
    ## use-ing A::A::Exception doesn't
    eval 'use Apache::AxKit::Exception';
    if (!$@) {
        push(@ARGV, '-defines', 'AXKIT');
    };

    Apache::TestMM::filter_args();
    Apache::TestMM::generate_script('t/TEST');
    Apache::TestMM::generate_script('t/SMOKE');

    mkdir($sessiondir);
    mkdir($sessionlockdir);
};

WriteMakefile(
    NAME            =>  'AxKit::XSP::Minisession',
    VERSION_FROM    =>  'lib/AxKit/XSP/Minisession.pm',
    ABSTRACT        =>  'Yet Another Session Handling Library',
    ($] >= 5.005 ?
        (AUTHOR     =>  'Christopher H. Laco (axkit@chrislaco.com)') : ()),
    PREREQ_PM       =>  {
        'AxKit'                 => 1.62,
        'Apache::Log'           => undef,
        'Apache::Session::File' => undef,
        'Apache::Cookie'        => undef
    },
    (ExtUtils::MakeMaker->VERSION >= 6.11) ?
    (NO_META      => 1) : (),
    clean           =>  {
        FILES => "t/TEST t/SMOKE smoke-report-* $sessiondir $sessionlockdir t/logs"
    }
);
