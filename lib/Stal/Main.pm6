unit module Stal::Main;

use Stal::Parse;

sub MAIN(**@source-files --> Nil)
    is export
{
    my @syntax-trees = @source-files.map: { $_, parse-source-file($_) } ∘ *.IO;
    say @syntax-trees;
}
