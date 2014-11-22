package MT::FieldTricks::Tags;

use strict;
use warnings;

use MT::FieldTricks::Util;

sub _no_sorted_field {
    my ($ctx) = @_;
    return $ctx->error(
        MT->translate(
            'Use mt:[_1] tag inside mt:EntrySortedFields or mt:EntrySortedFields.',
            $ctx->stash('tag')
        )
    );
}

sub hdlr_EntrySortedFields {
    my ( $ctx, $args, $cond ) = @_;

    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');

    my $e = $ctx->stash('entry')
        or return $ctx->_no_entry_error();

    my ( $fields ) = split( /\|/, $e->entry_prefs_field_options || '', 2 );
    $fields ||= '';

    my $result = '';
    foreach my $f ( split(/\s*,\s*/, $fields) ) {
        next if $f =~ /^(category|feedback|assets)$/;
        my $field = $ctx->{__stash}{field};
        if ( $f =~ /^customfield_(.+)$/ ) {
            my $basename = $1;
            $field = MT->model('field')->load({
                blog_id     => [ $e->blog_id, 0 ],
                basename    => $basename,
                obj_type    => $e->class,
            }) or next;
        }

        local $ctx->{__stash}{vars}{field_tricks_field} = $f;
        local $ctx->{__stash}{field} = $field;

        defined( my $out = $builder->build($ctx, $tokens) )
            || return $ctx->error($builder->errstr);
        $result .= $out;
    }

    $result;
}

sub hdlr_IfSortedFieldIsCustomField {
    my ( $ctx, $args, $cond ) = @_;
    my $f = $ctx->{__stash}{vars}{field_tricks_field} || return _no_sorted_field($ctx);
    $f =~ /^customfield_(.+)$/;
}

sub hdlr_SortedFieldType {
    my ( $ctx, $args ) = @_;
    my $f = $ctx->{__stash}{vars}{field_tricks_field} || return _no_sorted_field($ctx);
    if ( $f =~ /^customfield_(.+)$/ ) {
        $1;
    } else {
        $f;
    }
}

sub hdlr_SortedFieldValue {
    my ( $ctx, $args ) = @_;
    my $e = $ctx->stash('entry')
        or return $ctx->_no_entry_error();
    my $f = $ctx->{__stash}{vars}{field_tricks_field} || return _no_sorted_field($ctx);

    # Callback first
    my $res;
    my $callback = MT->instance->run_callbacks('field_tricks_tag_field_value', \$res, $ctx, $args);
    return if !defined $callback && $ctx->errstr;
    return $res if defined $res;

    # Default value handling
    if ( $f =~ /^customfield_(.+)$/ ) {
        $ctx->invoke_handler('CustomFieldValue', $args);
    } elsif ( $f =~ /^(title|excerpt|keywords)$/ ) {
        $ctx->invoke_handler(join('', $e->class, $f), $args);
    } elsif ( $f eq 'text' ) {
        $ctx->invoke_handler(join('', $e->class, 'body'), $args)
        . $ctx->invoke_handler(join('', $e->class, 'more'), $args);
    } else {
        '';
    }
}

sub hdlr_CustomFieldType {
    my ($ctx) = @_;
    require CustomFields::Template::ContextHandlers;
    my $field = $ctx->stash('field')
        or return CustomFields::Template::ContextHandlers::_no_field($ctx);
    return $field->type;
}

1;