# $Id: Makefile.PL 128 2005-02-05 18:32:55Z claco $
use ExtUtils::MakeMaker;
use File::Spec::Functions;
use File::Path;

my $sessiondir = catfile('t', 'htdocs', 'session');
my $sessionlockdir = catfile('t', 'htdocs', 'sessionlock');
my $test = catfile('t', 'TEST');

eval 'use Apache::Test 1.16';
if (!$@) {
    require Apache::TestMM;
    Apache::TestMM->import(qw(test clean));

    my @scripts = qw(t/TEST);

    Apache::TestMM::filter_args();
    Apache::TestMM::generate_script($test);

    mkdir($sessiondir);
    mkdir($sessionlockdir);
};

WriteMakefile(
    NAME            =>  'AxKit::XSP::Minisession',
    VERSION_FROM    =>  catfile('lib', 'AxKit', 'XSP', 'Minisession.pm'),
    ABSTRACT        =>  'Yet Another Session Handling Library',
    ($] >= 5.005 ?
        (AUTHOR     =>  'Christopher H. Laco (axkit@chrislaco.com)') : ()),
    PREREQ_PM       =>  {
        'AxKit'                 => undef,
        'Apache::Log'           => undef,
        'Apache::Session::File' => undef,
        'Apache::Cookie'        => undef
    },
    (ExtUtils::MakeMaker->VERSION >= 6.11) ?
    (NO_META      => 1) : (),
    clean           =>  {
        FILES => "$test $sessiondir $sessionlockdir"
    }
);
