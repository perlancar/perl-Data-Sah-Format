package Data::Sah::FormatJS;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use Log::Any::IfLOG '$log';

use Data::Sah::FormatCommon;
use IPC::System::Options;
use Nodejs::Util qw(get_nodejs_path);

our %SPEC;

our $Log_Formatter_Code = $ENV{LOG_SAH_FORMATTER_CODE} // 0;

$SPEC{gen_formatter} = {
    v => 1.1,
    summary => 'Generate formatter code',
    args => {
        %Data::Sah::FormatCommon::gen_formatter_args,
    },
    result_naked => 1,
};
sub gen_formatter {
    my %args = @_;

    my $format   = $args{format};
    my $pkg = "Data::Sah::Format::js\::$format";
    (my $pkg_pm = "$pkg.pm") =~ s!::!/!g;

    require $pkg_pm;

    my $fmt = &{"$pkg\::format"}(
        data_term => 'data',
        (args => $args{formatter_args}) x !!defined($args{formatter_args}),
    );

    my $code = join(
        "",
        "function (data) {\n",
        "    return ($fmt->{expr});\n",
        "}",
    );

    if ($Log_Formatter_Code) {
        $log->tracef("Formatter code (gen args: %s): %s", \%args, $code);
    }

    return $code if $args{source};

    state $nodejs_path = get_nodejs_path();
    die "Can't find node.js in PATH" unless $nodejs_path;

    sub {
        require File::Temp;
        require JSON::MaybeXS;
        #require String::ShellQuote;

        my $data = shift;

        state $json = JSON::MaybeXS->new->allow_nonref;

        # code to be sent to nodejs
        my $src = "var formatter = $code;\n\n".
            "console.log(JSON.stringify(formatter(".
                $json->encode($data).")))";

        my ($jsh, $jsfn) = File::Temp::tempfile();
        print $jsh $src;
        close($jsh) or die "Can't write JS code to file $jsfn: $!";

        my $out = IPC::System::Options::readpipe($nodejs_path, $jsfn);
        $json->decode($out);
    };
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Data::Sah::FormatJS qw(gen_formatter);

 # use as you would use Data::Sah::Format


=head1 DESCRIPTION

This module is just like L<Data::Sah::Format> except that it uses JavaScript
formatting modules.


=head1 VARIABLES

=head2 $Log_Formatter_Code => bool (default: from ENV or 0)

If set to true, will log the generated formatter code (currently using
L<Log::Any> at trace level). To see the log message, e.g. to the screen, you can
use something like:

 % TRACE=1 perl -MLog::Any::Adapter=Screen -MData::Sah::FormatJS=gen_formatter \
     -E'my $c = gen_formatter(...)'


=head1 ENVIRONMENT

=head2 LOG_SAH_FORMATTER_CODE => bool

Set default for C<$Log_Formatter_Code>.


=head1 SEE ALSO

L<Data::Sah::Format>

L<App::SahUtils>, including L<format-with-sah> to conveniently test formatting
from the command-line.
