package MT::FieldTricks::CMS::Entry;

use strict;
use warnings;

use MT::FieldTricks::Util;

sub template_param_cfg_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $blog = MT->model($param->{object_type})->load($param->{id})
        || return 1;

    for my $t ( qw/entry page/ ) {
        next if MT->version_number < 6.0 && !$blog->is_blog && $t eq 'entry';
        my $key = join('', $t, '_prefs_tweaks');
        my $tweaks = $app->registry('entry_prefs_tweaks') || {};
        my @tweaks = sort { $a->{order} <=> $b->{order} } grep { $_->{type} eq $t } map {
            $param->{$_} = $blog->$_
                if !defined($param->{$_}) && $blog->has_column($_);

            my $entry = $tweaks->{$_};
            my $id = $_;
            $id =~ s/_/-/g;
            $entry->{name} = $_;
            $entry->{id} = $id;
            $entry;
        } keys %$tweaks;

        my $label_prefix = $t eq 'entry' ? 'Entry' : 'Page';
        my $setting = $tmpl->createElement('app:setting', {
            label => plugin->translate( "$label_prefix Preference Tweak" ),
            id => $key,
        });

        $param->{$key} = \@tweaks;

        $setting->innerHTML(qq{
            <ul>
                <mt:loop name="${key}">
                <li>
                    <label for="<mt:var name='id'>">
                        <input type="checkbox" name="<mt:var name='name'>" id="<mt:var name='id'>"
                            value="1" <mt:if name="\$name">checked="checked"</mt:if>
                        >
                        <input type="hidden" name="<mt:var name='name'>" value="0">
                        <mt:var name="label">
                    </label>
                </li>
                </mt:loop>
            </ul>
        });

        if ( my $prefs = $tmpl->getElementById("${t}_fields") ) {
            $tmpl->insertAfter($setting, $prefs);
        }
    }

    1;
}

sub pre_save_blog {
    my ( $cb, $app, $blog ) = @_;
    my $q = $app->param;

    my $screen = $q->param('cfg_screen');
    return 1 if $screen ne 'cfg_entry';

    my $tweaks = $app->registry('entry_prefs_tweaks') || {};
    for my $c ( keys %$tweaks ) {
        $blog->$c($q->param($c)) if $blog->has_column($c);
    }

    1;
}

sub save_entry_prefs {
    my ( $app ) = @_;

    # Run original first
    require MT::CMS::Entry;
    defined ( my $result = MT::CMS::Entry::save_entry_prefs(@_) )
        or return;

    # Save as default if administrator
    my $q = $app->param;
    my $blog_id = $q->param('blog_id') || return $result;
    my $perms = $app->permissions;
    return $result unless $perms->can_administer_blog;

    # Copy to default
    my $prefs_type = $q->param('_type') . '_prefs';
    my $perm = MT->model('permission')->load({ blog_id => $blog_id, author_id => 0 });
    $perm->$prefs_type($app->permissions->$prefs_type);
    $perm->save;

    $result;
}

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $q = $app->param;
    my $blog = $app->blog || return 1;
    my $perms = $app->permissions || return 1;
    my $type = $param->{object_type};
    my $entry = $param->{id} ? MT->model($type)->load($param->{id}) : undef;

    # Current tweaks
    my $allow_hide_system_col = "${type}_prefs_allow_hide_system";
    my $allow_sort_system_col = "${type}_prefs_allow_sort_system";
    my $allow_only_admin_col = "${type}_prefs_allow_only_admin";
    my $use_each_field_options_col = "${type}_prefs_use_each_field_options";

    my $allow_hide_system = $blog->$allow_hide_system_col;
    my $allow_sort_system = $blog->$allow_sort_system_col;
    my $allow_only_admin = $blog->$allow_only_admin_col;
    my $use_each_field_options = $blog->$use_each_field_options_col;

    # Reload prefs
    my $prefs_type = "${type}_prefs";
    my $prefs = $perms->$prefs_type || '';

    my $available = 1;
    if ( $allow_only_admin && !$perms->can_administer_blog ) {
        $available = 0;
        my $perm = MT->model('permission')->load({
            blog_id => $blog->id,
            author_id => 0,
        });
        if ( $perm && $perm->$prefs_type ) {
            $prefs = $perm->$prefs_type;
        }
    }

    # Use options of each entry?
    if ( $entry && $use_each_field_options && defined $entry->entry_prefs_field_options ) {
        my $opts = $entry->entry_prefs_field_options;
        $prefs =~ s/^[^\|]*/$opts/;
    }
    $param->{entry_prefs_field_options} = $prefs;

    # Sort order and visibility
    my ( $fields ) = split(/\|/, $prefs, 2);
    my $order = 1;
    my %displays = map { $_ => $order++ } split( /\s*,\s*/, $fields || '' );

    # Reorder field loop if sortable
    if ( $allow_sort_system ) {
        my @reorder = sort {
            ( $displays{$a->{field_name}} || 999 )
                <=> ( $displays{$b->{field_name}} || 999 )
        } grep {
            $_->{show_field} = $displays{$_->{field_id}} ? 1 : 0;
            1;
        } @{$param->{field_loop}};

        $param->{field_loop} = \@reorder;
    }

    # Disable display options and sorting if allowed only for admin, and the user is not admin
    if ( $allow_only_admin && !$perms->can_administer_blog ) {

        # Cancel display options.
        my $include = $tmpl->getElementById('header_include');
        for my $cancel ( qw/display_options show_display_options_link/ ) {
            my $el = $tmpl->createElement('setvarblock', { name => $cancel });
            $tmpl->insertBefore( $el, $include );
        }

        # Swing and miss preference ajax saver.
        $param->{jq_js_include} .= q{
            // Swing and miss
            window.saveEntryFieldOptions = function(options) {};
        };

        # Switch classes of mtapp:setting to sort-disabled
        my $settings = $tmpl->getElementsByTagName('app:setting');
        for my $setting ( @$settings ) {
            my $attr = $setting->getAttribute('class');
            if ( defined($attr) && $attr eq 'sort-enabled' ) {
                $setting->setAttribute('class', 'sort-disabled');
            }
        }

        # Add CSS for class: .sort-disabled
        $param->{js_include} .= plugin->load_tmpl('sort_disabled_css.tmpl')->text;
    }

    # Field options of entry
    if ( my $status = $tmpl->getElementById('status') ) {
        my $if_true = $tmpl->createElement('if', { test => 1 });
        $if_true->innerHTML(q{
            <input
                type="hidden"
                id="entry_prefs_field_options"
                name="entry_prefs_field_options"
                value="<mt:var name='entry_prefs_field_options' escape='html'>"
            />
        });
        $tmpl->insertBefore($if_true, $status);
    }

    # Around title
    if ( my $title = $tmpl->getElementById('title') ) {
        if ( $allow_sort_system && $available ) {
            $title->setAttribute('class', 'sort-enabled');
            $title->setAttribute('label_class', 'field-top-label');
        }
        if ( $allow_hide_system ) {
            $title->setAttribute('shown', '$show_field');
        }
    }

    # Around text
    if ( my $text = $tmpl->getElementById('text') ) {
        if ( $available && $allow_sort_system ) {
            my $inner = $text->innerHTML;

            # Wrap with mtapp:setting like other
            $inner = q{
                  <mtapp:setting
                     id="$field_id"
                     class="sort-enabled"
                     label="$label_encoded"
                     label_class="field-top-label"
                     hint="$desc_encoded"
                     shown="$show_field"
                     content_class="$content_class"
                     show_hint="$show_hint"
                     required="$required">
                } . $inner . q{
                  </mtapp:setting>
                };

            $text->innerHTML($inner);
        } elsif ( $allow_hide_system ) {
            my $inner = $text->innerHTML;

            # Wrap with mtapp:setting no-header
            $inner = q{
                  <mtapp:setting
                     id="$field_id"
                     label="$label_encoded"
                     label_class="no-header"
                     shown="$show_field">
                } . $inner . q{
                  </mtapp:setting>
                };

            $text->innerHTML($inner);
        }
    }

    # Around field loop
    if ( $allow_hide_system ) {

        # Arrange fields loop
        my $field_loop = $param->{field_loop};
        for my $field ( @$field_loop ) {
            if ( my $name = $field->{field_name} ) {

                # They are always enabled with hard-corded
                if ( $name eq 'title' || $name eq 'text' || $name eq 'permalink') {

                    # No lock and system fields.
                    $field->{lock_field} = 0;
                    $field->{system_field} = 0;

                    # Show field override from prefs
                    $field->{show_field} = $displays{$name} ? 1: 0;
                }
            }
        }

        # No default fields.
        $param->{disp_prefs_default_fields} = [];

        # Override prefs ajax saver
        if ( $available ) {
            $param->{jq_js_include} .= q!
                // Override to drop hard-coded title,text in saveEntryFieldOptions
                var _saveEntryFieldOptionsToDropDefault = window.saveEntryFieldOptions;
                window.saveEntryFieldOptions = function(options) {
                    options.data = options.data.replace(/^title,text,?/, '');
                    jQuery('#entry_prefs_field_options').val(options.data);
                    _saveEntryFieldOptionsToDropDefault(options);
                };
            !;
        }
    }

    # Display position
    my @sidebars;
    my @new_loop;
    if ( my $field_loop = $param->{field_loop} ) {
        for my $field ( @$field_loop ) {
            my $remain = 1;
            if ( my $pos = $field->{field_tricks_pos} ) {
                if ( $field->{field_html} && $pos eq 'sidebar' ) {
                    $remain = 0;
                    push @sidebars, $field;
                }
            }
            push @new_loop, $field if $remain;
        }
    }

    $param->{field_loop} = \@new_loop;

    if ( @sidebars ) {
        $param->{field_tricks_sidebar_loop} = \@sidebars;

        my $publish_widget = $tmpl->getElementById('entry-publishing-widget');
        my $field_widget = $tmpl->createElement('app:widget', {
            id      => 'entry-field-tricks-widget',
            label   => plugin->translate('Custom Fields'),
        });

        $field_widget->innerHTML(<<'MTML');
<mt:loop id="content_fields" name="field_tricks_sidebar_loop">
  <mt:var name="field_label" escape="html" setvar="label_encoded">
  <mt:var name="description" escape="html" setvar="desc_encoded">

  <mtapp:setting
     id="$field_id"
     class=""
     label="$label_encoded"
     label_class="field-top-label"
     hint="$desc_encoded"
     shown="1"
     content_class="$content_class"
     show_hint="$show_hint"
     required="$required">
    <$mt:var name="field_html"$>
  </mtapp:setting>
</mt:loop>
MTML

        $tmpl->insertBefore($field_widget, $publish_widget);
    }

    1;
}

sub pre_save_entry {
    my ( $cb, $app, $obj ) = @_;

    $obj->entry_prefs_field_options($app->param('entry_prefs_field_options'));

    1;
}

1;