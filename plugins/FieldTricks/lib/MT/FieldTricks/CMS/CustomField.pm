package MT::FieldTricks::CMS::CustomField;

use strict;
use warnings;

use MT::FieldTricks::Util;

sub template_param_list_common {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $include = $tmpl->getElementById('header_include');
    my $node = $tmpl->createElement('setvarblock', { name => 'system_msg', append => 1 });
    $node->innerHTML(q(
        <__trans_section component="FieldTricks">
        <mt:if name="field_tricks_copied">
            <mtapp:statusmsg
                id="field-tricks-copied"
                class="success">
                <__trans phrase="Successfully copied from [_1] fields." params="<mt:var name='field_tricks_copied' />">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="field_tricks_copy_from">
            <mtapp:statusmsg
                id="field-tricks-copy-from"
                class="success">
                <__trans phrase="Successfully copied from [_1] fields to [_2] fields." params="<mt:var name='field_tricks_copy_from' />%%<mt:var name='field_tricks_copy_to' />">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="field_tricks_pos">
            <mtapp:statusmsg
                id="field-tricks-pos"
                class="success">
                <__trans phrase="Set display position of [_1] field(s) to [_2]." params="<mt:var name='field_tricks_count' _default="0" />%%<mt:var name='field_tricks_pos' />">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="field_tricks_error">
            <mtapp:statusmsg
                id="field-tricks-error"
                class="error">
                <mt:var name="field_tricks_error">
            </mtapp:statusmsg>
        </mt:if>
        </__trans_section>
    ));
    $tmpl->insertBefore($node, $include);

    foreach my $key ( qw(copied copy_from copy_to count pos error) ) {
        my $p = "field_tricks_$key";
        $param->{$p} = $app->param($p);
    }

    1;
}

sub template_param_edit_field {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $field = $tmpl->createElement('app:setting', {
        id      => 'display_in_widget',
        label   => '<__trans_section component="FieldTricks"><__trans phrase="Display in Sidebar"></__trans_section>',
        show_hint => 1,
        hint    => '<__trans_section component="FieldTricks"><__trans phrase="Check to display this custom field in widget of sidebar of edit entry screen."></__trans_section>',
    });

    $field->innerHTML(q(
        <__trans_section component="FieldTricks">
        <ul>
            <li>
                <label>
                    <input type="radio" name="field_tricks_pos" value="main"<mt:unless name="field_tricks_pos" eq="sidebar"> checked="checked"</mt:unless>>
                    <__trans phrase="Display in Main">
                </label>
            </li>
            <li>
                <label>
                    <input type="radio" name="field_tricks_pos" value="sidebar"<mt:if name="field_tricks_pos" eq="sidebar"> checked="checked"</mt:if>>
                    <__trans phrase="Display in Sidebar">
                </label>
            </li>
        </ul>
        </__trans_section>
    ));

    my $after = $tmpl->getElementById('tag');
    $tmpl->insertAfter($field, $after);

    1;
}

sub pre_save_field {
    my ( $cb, $app, $obj, $orig ) = @_;

    my $field_tricks_pos = $app->param('field_tricks_pos') || '';
    $field_tricks_pos = '' if $field_tricks_pos ne 'sidebar';

    $obj->field_tricks_pos($field_tricks_pos);

    1;
}

sub _bulk_set_display {
    my ( $value, $app ) = @_;

    $app->validate_magic or return;
    my $user = $app->user;
    my $xhr = $app->param('xhr');
    my @id  = $app->param('id');

    my $count = 0;
    if ( my $iter = MT->model('field')->load_iter({id => [@id]}) ) {
        while( my $field = $iter->() ) {
            next unless is_user_editable_the_field($user, $field);
            $value = '' if $value ne 'sidebar';
            $field->field_tricks_pos($value);
            $field->save;
            $count++;
        }
    }

    # TODO handle if 0

    return_list_action( $app, $xhr,
        return_args => { 'field_tricks_count' => $count, 'field_tricks_pos' => plugin->translate($value) },
        cls => 'success',
        msg => plugin->translate('Set display position of [_1] field(s) to [_2].', $count, plugin->translate($value)),
    );
}

sub bulk_display_in_sidebar {
    _bulk_set_display('sidebar', @_);
}

sub bulk_display_in_main {
    _bulk_set_display('main', @_);
}

sub display_positions {
    my @options = (
        { value => 'sidebar', label => plugin->translate('sidebar') },
        # TODO
        # { value => '', label => plugin->translate('main') },
    );

    \@options;
}

sub return_list_action {
    my ( $app, $xhr, %opts ) = @_;
    if ( my $return_args = $opts{return_args} ) {
        $app->add_return_arg( %$return_args );
    }
    return $xhr
        ? {
            messages => [
                {
                    cls => $opts{cls},
                    msg => $opts{msg},
                }
            ]
        }
        : $app->call_return;
}

sub copy_fields {
    my $app = shift;
    $app->validate_magic or return;
    my $user = $app->user;

    my $xhr = $app->param('xhr');
    my @id  = $app->param('id');

    my $amount = int($app->param('itemset_action_input')) or return;

    my $pattern = $app->config('FieldTricksCopyPattern');
    $pattern = eval { qr($pattern) } if $pattern && !ref $pattern;
    $pattern = /^(.+?)\s*(\d*)$/ if ref $pattern ne 'Regexp';

    my $format = $app->config('FieldTricksCopyFormat') || '%d';
    my @cols = split /\s*,\s*/, ( $app->config('FieldTricksCopyColumns') || 'name,basename,tag' );

    my @fields = MT->model('field')->load({id => \@id});

    my $copied_fields = 0;
    foreach my $field ( @fields ) {
        # Check permission
        next unless is_user_editable_the_field($user, $field);

        my @scope_fields = MT->model('field')->load({blog_id => $field->blog_id});
        my %exists;
        foreach my $field ( @scope_fields ) {
            foreach my $col ( @cols ) {
                $exists{$col} ||= {};
                $exists{$col}->{$field->$col} = 1;
            }
        }

        my %stems;
        my @indices;
        foreach my $col ( @cols ) {
            my $val = $field->$col;
            my ( $stem, $index ) = ( $val =~ $pattern );
            push @indices, $index if $index;
            $stems{$col} = defined $stem && $stem ne '' ? $stem : $col;
        }

        my $index = (sort { $a <=> $b } @indices)[0];

        COPY: for ( my $i = 0; $i < $amount; ) {
            $index ++;
            local $@;
            eval {
                no warnings 'exiting';
                my %values;
                foreach my $col ( @cols ) {
                    my $value = $stems{$col} . sprintf($format, $index);
                    next COPY if $exists{$col}->{$value};
                    $values{$col} = $value;
                }
                $field->set_values(\%values);
                delete $field->{column_values}->{id};
                $field->save;
                foreach my $col ( @cols ) {
                    $exists{$col}->{$values{$col}} = 1;
                }
            };
            $i ++;
        }

        $copied_fields ++;
    }

    return_list_action( $app, $xhr,
        return_args => { field_tricks_copied => $copied_fields },
        cls => 'success',
        msg => plugin->translate(
            'Successfully copied [_1] fields from [_2] of each field.',
            $amount, $copied_fields
        ),
    );
}

sub copy_fields_to_another_blog {
    my $app = shift;
    $app->validate_magic or return;
    my $user = $app->user;

    my $xhr = $app->param('xhr');

    my $blog_ids = $app->param('itemset_action_input');
    my @blog_ids = grep { $_ } map { int($_) } split( /\s*,\s*/, $blog_ids );
    my @blogs = map { MT->model('blog')->load($_) } @blog_ids;
    @blogs || return return_list_action( $app, $xhr,
        return_args => { field_tricks_error => plugin->translate('No blogs found ids of [_1].', $blog_ids) },
        cls => 'error',
        msg => plugin->translate('No blogs found ids of [_1].', $blog_ids),
    );

    my @id  = $app->param('id');
    my @fields = MT->model('field')->load({id => \@id});

    my $copied_fields = 0;
    foreach my $blog ( @blogs ) {
        unless ( is_user_editable_fields_on_blog($user, $blog) ) {
            return return_list_action( $app, $xhr,
                return_args => { field_tricks_error => plugin->translate('Fields on blog "[_1]" is not editable to you.', $blog->name) },
                cls => 'error',
                msg => plugin->translate('Blog id of "[_1]" is not found.', $blog->name),
            );
        }

        foreach my $field ( @fields ) {
            return return_list_action( $app, $xhr,
                return_args => { field_tricks_error => plugin->translate('Field basenamed "[_1]" exists on blog "[_2]".', $field->basename, $blog->name) },
                cls => 'error',
                msg => plugin->translate('Field basenamed "[_1]" exists on blog "[_2]".', $field->basename, $blog->name),
            ) if MT->model('field')->exist({ blog_id => $blog->id, basename => $field->basename });

            return return_list_action( $app, $xhr,
                return_args => { field_tricks_error => plugin->translate('Field tag named "[_1]" exists on blog "[_2]".', $field->tag, $blog->name) },
                cls => 'error',
                msg => plugin->translate('Field tag named "[_1]" exists on blog "[_2]".', $field->tag, $blog->name),
            ) if MT->model('field')->exist({ blog_id => $blog->id, tag => $field->tag });
        }

        foreach my $field ( @fields ) {
            $field->blog_id($blog->id);
            delete $field->{column_values}->{id};
            $field->save;
            $copied_fields ++;
        }
    }

    return_list_action( $app, $xhr,
        return_args => { 'field_tricks_copy_from' => scalar @fields, 'field_tricks_copy_to' => $copied_fields },
        cls => 'success',
        msg => plugin->translate( 'Successfully copied from [_1] fields to [_2] fields.', scalar @fields, $copied_fields ),
    );
}

1;