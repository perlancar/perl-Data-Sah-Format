package Data::Sah::FormatCommon;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';

my %common_args = (
    format => {
        schema => ['str*', match=>qr/\A\w+(::\w+)*\z/],
        req => 1,
        pos => 0,
    },
    formatter_args => {
        schema => 'hash*',
    },
);

my %gen_formatter_args = (
    %common_args,
    source => {
        summary => 'If set to true, will return formatter source code string'.
            ' instead of compiled code',
        schema => 'bool',
    },
);

1;
# ABSTRACT: Common stuffs for Data::Sah::Format and Data::Sah::FormatJS
