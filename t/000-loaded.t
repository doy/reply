#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Reply');
    use_ok('Reply::App');
    use_ok('Reply::Config');
    use_ok('Reply::Util');
    use_ok('Reply::Plugin');

    use_ok('Reply::Plugin::Colors');
    use_ok('Reply::Plugin::DataDumper');
    use_ok('Reply::Plugin::Defaults');
    use_ok('Reply::Plugin::FancyPrompt');
    use_ok('Reply::Plugin::Hints');
    use_ok('Reply::Plugin::Interrupt');
    use_ok('Reply::Plugin::LexicalPersistence');
    use_ok('Reply::Plugin::LoadClass');
    use_ok('Reply::Plugin::Packages');
    use_ok('Reply::Plugin::ReadLine');
    use_ok('Reply::Plugin::ResultCache');
    use_ok('Reply::Plugin::Timer');

    use_ok('Reply::Plugin::Autocomplete::Commands');
    use_ok('Reply::Plugin::Autocomplete::Functions');
    use_ok('Reply::Plugin::Autocomplete::Globals');
    use_ok('Reply::Plugin::Autocomplete::Lexicals');
    use_ok('Reply::Plugin::Autocomplete::Methods');
    use_ok('Reply::Plugin::Autocomplete::Packages');

    use_ok('Reply::Plugin::AutoRefresh')            if eval { require Class::Refresh;     1 };
    use_ok('Reply::Plugin::CollapseStack')          if eval { require Carp::Always;       1 };
    use_ok('Reply::Plugin::DataDump')               if eval { require Data::Dump;         1 };
    use_ok('Reply::Plugin::DataPrinter')            if eval { require Data::Printer;      1 };
    use_ok('Reply::Plugin::Editor')                 if eval { require Proc::InvokeEditor; 1 };
    use_ok('Reply::Plugin::Nopaste')                if eval { require App::Nopaste;       1 };
    use_ok('Reply::Plugin::Autocomplete::Keywords') if eval { require B::Keywords;        1 };
}

done_testing;