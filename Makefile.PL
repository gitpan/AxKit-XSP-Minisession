use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'AxKit::XSP::Minisession',
    VERSION_FROM => 'lib/AxKit/XSP/Minisession.pm',
    ABSTRACT     => 'Yet Another Session Handling Library',
    ($] >= 5.005 ?
        (AUTHOR   => 'Christopher H. Laco (axkit@chrislaco.com)') : ()),
    PREREQ_PM    => {
        'AxKit'                 => undef,
        'Apache::Log'           => undef,
        'Apache::Session::File' => undef,
        'Apache::Cookie'        => undef
    }
);
