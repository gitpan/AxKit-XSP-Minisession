# $Id: 004_xsp.t,v 1.3 2004/11/25 01:26:06 claco Exp $
# Using require instead of use to avoid redefining errors
# when Apache::Test < 1.16 is installed
require Test::More;

eval 'use Apache::Test 1.16';
Test::More::plan(skip_all =>
        'Apache::Test 1.16 required for AxKit Taglib tests') if $@;

eval 'use LWP::UserAgent';
Test::More::plan(skip_all =>
        'LWP::UserAgent required for Apache::Test cookie tests') if $@;

Apache::TestRequest->import(qw(GET));
Apache::TestRequest::user_agent( cookie_jar => {});
Apache::Test::plan(tests => 3, need('AxKit', 'mod_perl', &have_apache(1), &
have_lwp));

my $setreq = GET('/set-value.xsp');
ok($setreq->code == 200);

my $getreq = GET('/get-value.xsp');
ok($getreq->code == 200);

ok( $getreq->content =~ /<body>claco<\/body\>/i );

