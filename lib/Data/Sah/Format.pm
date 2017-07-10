package Data::Sah::Format;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use Log::ger;

use Data::Sah::FormatCommon;

our %SPEC;

our $Log_Formatter_Code = $ENV{LOG_SAH_FORMATTER_CODE} // 0;

$SPEC{gen_formatter} = {
    v => 1.1,
    summary => 'Generate formatter code',
    args => {
        %Data::Sah::FormatterCommon::gen_formatter_args,
    },
    result_naked => 1,
};
sub gen_formatter {
    my %args = @_;

    my $format   = $args{format};
    my $pkg = "Data::Sah::Format::perl\::$format";
    (my $pkg_pm = "$pkg.pm") =~ s!::!/!g;

    require $pkg_pm;

    my $fmt = &{"$pkg\::format"}(
        data_term => '$data',
        (args => $args{formatter_args}) x !!defined($args{formatter_args}),
    );

    my $code;

    my $code_require .= '';
    #my %mem;
    if ($fmt->{modules}) {
        for my $mod (keys %{$fmt->{modules}}) {
            #next if $mem{$mod}++;
            $code_require .= "require $mod;\n";
        }
    }

    $code = join(
        "",
        $code_require,
        "sub {\n",
        "    my \$data = shift;\n",
        "    $fmt->{expr};\n",
        "}",
    );

    if ($Log_Formatter_Code) {
        log_trace("Formatter code (gen args: %s): %s", \%args, $code);
    }

    return $code if $args{source};

    my $formatter = eval $code;
    die if $@;
    $formatter;
}

1;
# ABSTRACT: Formatter for Data::Sah

=head1 SYNOPSIS

 use Data::Sah::Format qw(gen_formatter);

 my $c = gen_formatter(
     format => 'iso8601_date',
     #format_args => {...},
 );

 my $val;
 $val = $c->(1465784006);   # "2016-06-13"
 $val = $c->(DateTime->new(year=>2016, month=>6, day=>13)); # "2016-06-13"
 $val = $c->("2016-06-13"); # unchanged
 $val = $c->("9999-99-99"); # unchanged
 $val = $c->("foo");        # unchanged
 $val = $c->([]);           # unchanged


=head1 DESCRIPTION


=head1 VARIABLES

=head2 $Log_Formatter_Code => bool (default: from ENV or 0)

If set to true, will log the generated formatter code (currently using
L<Log::ger> at trace level). To see the log message, e.g. to the screen, you can
use something like:

 % TRACE=1 perl -MLog::ger::LevelFromEnv -MLog::ger::Output=Screen \
     -MData::Sah::Format=gen_formatter -E'my $c = gen_formatter(...)'


=head1 ENVIRONMENT

=head2 LOG_SAH_FORMATTER_CODE => bool

Set default for C<$Log_Formatter_Code>.


=head1 SEE ALSO

L<Data::Sah>

L<Data::Sah::FormatterJS>

L<App::SahUtils>, including L<format-with-sah> to conveniently test formatting
from the command-line.
