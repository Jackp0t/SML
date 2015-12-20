use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

use lib "../lib";

use SML::Library;

my $library = SML::Library->new(config_filename=>'library.conf');

$library->get_all_entities;

$library->publish('sml',    'html','default');
$library->publish('frd-sml','html','default');
$library->publish('sdd-sml','html','default');
$library->publish('ted-sml','html','default');

$library->publish_index;

1;
