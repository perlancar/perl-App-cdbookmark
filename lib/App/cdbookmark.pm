package App::cdbookmark;

use 5.010001;
use strict;
use warnings;
use Log::ger;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{cdbookmark_backend} = {
    v => 1.1,
    summary => 'Change directory to one from the list',
    description => <<'MARKDOWN',

In `~/.config/cdbookmark.conf`, put your directory bookmarks:

    bookmarks = ~/dir1
    bookmarks = /etc/dir2
    bookmarks = /home/u1/Downloads

Then in your shell startup:

    cdbookmark() { cd `cdbookmark-backend "$1"`; }

To use:

    % cdbookmark 1; # cd to the first item (~/dir1)
    % cdbookmark Downloads;   # cd to the most similar item, which is /home/u1/Downloads

MARKDOWN
    args => {
        bookmarks => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'bookmark',
            schema => ['array*', of=>'dirname*'],
        },
        item => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
    },
};
sub cdbookmark_backend {
    my %args = @_;
    defined(my $bookmarks = $args{bookmarks}) or return [200, "Error: please defined bookmarks", "."];
    defined(my $item = $args{item}) or return [200, "Error: please specify argument", "."];

    if ($item =~ /\A\d+\z/) {
        if (scalar(@$bookmarks) < $item) { return [200, "Error: no bookmark item #$item", "."] }
        return [200, "OK", $bookmarks->[$item-1]];
    }

    require Sort::BySimilarity;
    my @items = Sort::BySimilarity::sort_by_similarity(0, 0, {string=>$item}, @$bookmarks);
    return [200, "OK", $items[0]];
}

1;
#ABSTRACT:

=head1 SYNOPSIS


=head1 DESCRIPTION

=cut
