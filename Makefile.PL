# $Id: Makefile.PL,v 1.3 2004/11/25 01:20:33 claco Exp $
use ExtUtils::MakeMaker;
use File::Spec::Functions;

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

	mkdir($sessiondir, 777);
	mkdir($sessionlockdir, 777);
};

WriteMakefile(
	NAME			=>	'AxKit::XSP::Minisession',
	VERSION_FROM	=>	catfile('lib', 'AxKit', 'XSP', 'Minisession.pm'),
	ABSTRACT		=>	'Yet Another Session Handling Library',
	($] >= 5.005 ?
		(AUTHOR		=>	'Christopher H. Laco (axkit@chrislaco.com)') : ()),
	PREREQ_PM		=>	{
		'AxKit'					=> undef,
		'Apache::Log'			=> undef,
		'Apache::Session::File'	=> undef,
		'Apache::Cookie'		=> undef
	},
	clean			=>	{
		FILES => "$test $sessiondir $sessionlockdir"
	}
);
