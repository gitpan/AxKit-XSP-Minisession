package AxKit::XSP::Minisession;
use vars qw/@ISA $VERSION $NS/;
$VERSION = "0.02";
@ISA = ('Apache::AxKit::Language::XSP');
$NS = 'http://squash.oucs.ox.ac.uk/XSP/Minisession';
sub start_document { 'use Apache::Log;' }

sub parse_char {
  my ($e, $text) = @_;
  $text =~ s/^\s*//;
  $text =~ s/\s*$//;

  return '' unless $text;

  $text = Apache::AxKit::Language::XSP::makeSingleQuoted($text);
  return ". $text";
}

sub parse_end {
    my ($e, $tag, %attr) = @_;
    $tag =~ s/-/_/g;
    if ($tag eq "set_value") {
    } elsif ($tag eq "get_value") { 
	$e->manage_text(0);
	$e->append_to_script("\";AxKit::XSP::Minisession::Backend::get_value(\$r, \$flange);\n");
        $e->end_expr();
        return "";
    } else { die "Unknown tag $tag\n" }
}

sub parse_start {
    my ($e, $tag, %attr) = @_;
    $tag =~ s/-/_/g;
    if ($tag eq "get_value") {
        $e->start_expr($tag);
        $e->manage_text(1);
        return 'my $flange = "';
    } elsif ($tag eq "set_value") {
        $e->manage_text(0);
        my $buildup = '';
        $buildup .= "\$r->log->debug('calling put_value');AxKit::XSP::Minisession::Backend::put_value(\$r, ".
                Apache::AxKit::Language::XSP::makeSingleQuoted($_)
          .", ". Apache::AxKit::Language::XSP::makeSingleQuoted($attr{$_})
            .");\n"
            for keys %attr;
        return $buildup;
    }
}

package AxKit::XSP::Minisession::Backend;

use Apache::Log;
use Apache::Session::File;
use Apache::Cookie;

sub get_session {
    my $r = shift;
    my $sid;

    # Has it come from the fixup handler?
    if (!($sid = $r->pnotes("SESSION_ID"))) {
        # Has it come from a cookie?
        my %jar = Apache::Cookie->new($r)->parse;
        if (exists $jar{sessionid}) {
            $sid = $jar{sessionid}->value();
            $r->log->debug("Got the session id ($sid) from a cookie");
        }
    }

    $sid = undef unless $sid; # Clear it, as 0 is a valid sid.
    my %session = ();
    my $new = !(defined $sid);

    $r->log->debug(defined $sid ? "Retrieving session $sid" 
                   : "Creating a new session"); 

    tie %session, 'Apache::Session::File', $sid, {
        Directory     => $r->dir_config("MinisessionDir") || "/tmp/sessions",
        LockDirectory => $r->dir_config("MinisessionLockDir") || "/tmp/sessionlock",
    };

    $r->pnotes("SESSION", { %session });
    $r->log->debug("Session contains @{[%session]}");
    if ($new) {
       put_session($r, \%session);
    }
    return \%session;
}

sub put_session {
    my ($r, $sess_ref) = @_;
    $r->log->debug("Returning session ".$sess_ref->{_session_id}." to the cookie jar");
    my $cookie = Apache::Cookie->new($r,
        -name => "sessionid",
        -value => $sess_ref->{_session_id},
        -path => "/"
    );
    $cookie->bake();
    $r->pnotes("SESSION", { %$sess_ref });
    untie $sess_ref;
}

sub get_value {
    my $r = shift;
    my $key = shift;
    my $sref = get_session($r);
    $r->log->debug("get_value saw session ".$sref->{_session_id});
    $r->log->debug("retrieving $key -> $sref->{$key}");
    return $sref->{$key};
}

sub put_value {
    my $r = shift;
    my $key = shift;
    my $val = shift;
    my $sref = get_session($r);
    $r->log->debug("set_value saw session ".$sref->{_session_id}. ", setting $key to $val");
    $sref->{$key} = $val;
    put_session($r, $sref);
    return undef; # To stop xsp leakage.
}


1;

=head1 NAME

AxKit::XSP::Minisession - Yet Another Session Handling Library

=head1 SYNOPSIS

In your config file:

    PerlSetVar MinisessionDir /tmp/sessions
    PerlSetVar MinisessionLockDir /tmp/sessionlock
    AxAddXSPTaglib +AxKit::XSP::Minisession

In your XSP code:

    <xsp:page
        xmlns:s="http://squash.oucs.ox.ac.uk/XSP/Minisession"
    >

    <s:set-value username="simon"/>
    <s:get-value>username</s:get-value>

In your Perl code:

    die "Already logged in" if
        AxKit::XSP::Minisession::Backend::get_value($r, "username");
    AxKit::XSP::Minisession::Backend::set_value($r, "username", $username);

=head1 DESCRIPTION

This is a very simple session library which sets state via a cookie and
uses C<Apache::Session::File> to store sessions in files on the
filesystem. If you need anything more complex than that, this module
isn't for you.

The guts of the module are the two functions C<get_value> and
C<set_value> in the C<::Backend> module. The first parameter to these
should be an C<Apache::Request> object, and the second a hash key. 

These functions are wrapped by the C<set-value> and C<get-value> tags
from XSP.

And that's it. I said it was very simple.

=head1 AUTHOR

Simon Cozens C<simon@cpan.org>

