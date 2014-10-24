package MT::FieldTricks::L10N::ja;

use strict;
use utf8;
use base 'MT::FieldTricks::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
    'Copy Fields...' => 'カスタムフィールドをコピー',
    'Copy To Another Blog or Website...' => '他のブログやウェブサイトにコピー',
    'Successfully copied [_1] fields from [_2] of each field.'
        => '[_2]件のカスタムフィールドに対し、それぞれ[_1]個のコピーを作成しました。',
    'Successfully copied from [_1] fields.' => '[_1]件のカスタムフィールドからコピーを作成しました。',
    'Amount to copy fields' => 'コピーを作成する数',
    'Blog or Website ID to copy fields to' => 'カスタムフィールドをコピーする先のブログまたはウェブサイトのID',
    'Blog id of "[_1]" is not found.' => 'ID([_1])のブログが見つかりません。',
    'Fields on blog "[_1]" is not editable to you.' => 'ブログ「[_1]」のカスタムフィールドを操作する権限がありません。',
    'Field basenamed "[_1]" exists on blog "[_2]".' => '"[_1]"というベースネームを持つカスタムフィールドがブログ「[_2]」にはすでに存在します。',
    'Field tag named "[_1]" exists on blog "[_2]".' => '"[_1]"というタグ名を持つカスタムフィールドがブログ「[_2]」にはすでに存在します。',

    'Entry And Page Preference Customizer' => 'ブログ記事・ウェブページ表示設定カスタマイズ',
    'Open Settings > Compose to customize preference on each blog/website.' => '表示設定をカスタマイズするには各ブログ/ウェブサイトで 設定 > 投稿 を開いてください',
    'Entry Preference Tweak' => 'ブログ記事の表示設定',
    'Page Preference Tweak' => 'ウェブページの表示設定',
    'Allow to hide title field and body editor.' => 'タイトルと本文エディタの非表示を可能にします',
    'Allow to sort title field and body editor.' => 'タイトルと本文エディタの並べ替えを可能にします',
    'Allow to change preference only for blog/website administrator and share it to non-administrators.' => 'ブログ/ウェブサイト管理者のみ表示オプションの変更を許可し、管理者でないユーザーに適用します',
    'Use fields order saved to each entry.' => 'それぞれの記事またはウェブページに保存されたフィールドの並び順を使用します。'
);

1;

