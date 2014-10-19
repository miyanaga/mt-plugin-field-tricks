package MT::FieldTricks::CMS::CustomField;

use strict;
use warnings;

use MT::FieldTricks::Util;

sub template_param_list_common {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $include = $tmpl->getElementById('header_include');
    my $node = $tmpl->createElement('setvarblock', { name => 'system_msg', append => 1 });
    $node->innerHTML(q(
        <mt:if name="field_tricks_copied">
            <__trans_section component="FieldTricks">
            <mtapp:statusmsg
                id="field-tricks-copied"
                class="success">
                <__trans phrase="Successfully copied from [_1] fields." params="<mt:var name='field_tricks_copied' />">
            </mtapp:statusmsg>
            </__trans_section>
        </mt:if>
        <mt:if name="field_tricks_error">
            <__trans_section component="FieldTricks">
            <mtapp:statusmsg
                id="field-tricks-error"
                class="error">
                <mt:var name="field_tricks_error">
            </mtapp:statusmsg>
            </__trans_section>
        </mt:if>
    ));
    $tmpl->insertBefore($node, $include);
    $param->{field_tricks_copied} = $app->param('field_tricks_copied');
    $param->{field_tricks_error} = $app->param('field_tricks_error');

    1;
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
    my $blog_id = $app->param('itemset_action_input');
    my $blog = MT->model('blog')->load($blog_id)
        || return return_list_action( $app, $xhr,
            return_args => { field_tricks_error => plugin->translate('Blog id of "[_1]" is not found.', $blog_id) },
            cls => 'error',
            msg => plugin->translate('Blog id of "[_1]" is not found.', $blog_id),
        );

    unless ( is_user_editable_fields_on_blog($user, $blog) ) {
        return return_list_action( $app, $xhr,
            return_args => { field_tricks_error => plugin->translate('Fields on blog "[_1]" is not editable to you.', $blog->name) },
            cls => 'error',
            msg => plugin->translate('Blog id of "[_1]" is not found.', $blog->name),
        );
    }

    my @id  = $app->param('id');
    my @fields = MT->model('field')->load({id => \@id});

    my $copied_fields = 0;
    foreach my $field ( @fields ) {
        return return_list_action( $app, $xhr,
            return_args => { field_tricks_error => plugin->translate('Field basenamed "[_1]" exists on blog "[_2]".', $field->basename, $blog->name) },
            cls => 'error',
            msg => plugin->translate('Field basenamed "[_1]" exists on blog "[_2]".', $field->basename, $blog->name),
        ) if MT->model('field')->exist({ blog_id => $blog_id, basename => $field->basename });

        return return_list_action( $app, $xhr,
            return_args => { field_tricks_error => plugin->translate('Field tag named "[_1]" exists on blog "[_2]".', $field->tag, $blog->name) },
            cls => 'error',
            msg => plugin->translate('Field tag named "[_1]" exists on blog "[_2]".', $field->tag, $blog->name),
        ) if MT->model('field')->exist({ blog_id => $blog_id, tag => $field->tag });
    }

    foreach my $field ( @fields ) {
        $field->blog_id($blog_id);
        delete $field->{column_values}->{id};
        $field->save;
        $copied_fields ++;
    }

    return_list_action( $app, $xhr,
        return_args => { 'field_tricks_copied' => $copied_fields },
        cls => 'success',
        msg => plugin->translate( 'Successfully copied from [_1] fields.', $copied_fields ),
    );
}

1;