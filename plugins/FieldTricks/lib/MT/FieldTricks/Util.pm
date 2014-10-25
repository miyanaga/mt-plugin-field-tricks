package MT::FieldTricks::Util;

use strict;
use warnings;
use base qw(Exporter);

use Data::Dumper;

our @EXPORT = qw(plugin pp is_user_editable_the_field is_user_editable_fields_on_blog);

sub plugin { MT->component('FieldTricks') }

sub pp { print STDERR Dumper(@_); }

sub is_user_editable_the_field {
    my ( $user, $field ) = @_;

    return 1 if $user->is_superuser;
    my %can_do = ( at_least_one => 1 );
    $can_do{blog_id} = [ 0, $field->blog_id ] if $field->blog_id;

    $user->can_do('edit_custom_fields', %can_do);
}

sub is_user_editable_fields_on_blog {
    my ( $user, $blog ) = @_;
    return 1 if $user->is_superuser;
    $user->can_do('edit_custom_fields', at_least_one => 1, blog_id => [0, $blog->id]);
}

1;