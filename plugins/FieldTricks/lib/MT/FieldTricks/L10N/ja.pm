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
    'Successfully copied from [_1] fields to [_2] fields.' => '[_1]件のカスタムフィールドから[_2]件のコピーを作成しました。',
    'Successfully copied from [_1] fields.' => '[_1]件のカスタムフィールドをコピーしました。',
    'Amount to copy fields' => 'コピーを作成する数',
    'Blog or Website ID or comma separated IDs to copy fields to' => 'カスタムフィールドをコピーする先のブログまたはウェブサイトのIDまたはカンマ区切りの複数ID',
    'No blogs found ids of [_1].' => 'ID([_1])のブログがいずれも見つかりません。',
    'Fields on blog "[_1]" is not editable to you.' => 'ブログ「[_1]」のカスタムフィールドを操作する権限がありません。',
    'Field basenamed "[_1]" exists on blog "[_2]".' => '"[_1]"というベースネームを持つカスタムフィールドがブログ「[_2]」にはすでに存在します。',
    'Field tag named "[_1]" exists on blog "[_2]".' => '"[_1]"というタグ名を持つカスタムフィールドがブログ「[_2]」にはすでに存在します。',

    'Edit Display Options (If Restricted)' => '表示オプションの編集(制限時のみ)',

    'Entry And Page Preference Customizer' => 'ブログ記事・ウェブページ表示設定カスタマイズ',
    'Open Settings > Compose to customize preference on each blog/website.' => '表示設定をカスタマイズするには各ブログ/ウェブサイトで 設定 > 投稿 を開いてください',
    'Entry Preference Tweak' => 'ブログ記事の表示設定',
    'Page Preference Tweak' => 'ウェブページの表示設定',
    'Allow to hide title field and body editor.' => 'タイトルと本文エディタの非表示を可能にします',
    'Allow to sort title field and body editor.' => 'タイトルと本文エディタの並べ替えを可能にします',
    'Allow to change preference only for permitted users and share it to not permitted users.'
        => '許可されたユーザーにのみ表示オプションの変更を許可し、それ以外のユーザーに適用します',
    'For example, it lets designers to fix fields order and to allow only writing to writers. The permission is "Edit Display Options" on roles.'
        => '例えば、デザイナーがフィールドの表示順を固定し、ライターにはその内容の記述のみを許可できます。その権限はロールで設定できる「表示オプションの編集」です。',
    'Use fields order saved to each entry.' => 'それぞれの記事またはウェブページごとにフィールドの並び順を保存します',
    'You can loop the fields order by mt:EntrySortedFields and mt:PageSortedFields template tags.'
        => 'そのフィールドの並び順はmt:EntrySortedFieldsとmt:PageSortedFieldsテンプレートタグで展開できます。',

    'Use mt:[_1] tag inside mt:EntrySortedFields or mt:EntrySortedFields.'
        => 'mt:[_1]テンプレートタグは、mt:EntrySortedFields または mt:PageSortedFields の内部で使用してください。',

    'Display in Sidebar' => 'サイドバーに表示',
    'Check to display this custom field in widget of sidebar of edit entry screen.'
        => '記事またはウェブページの編集画面で、サイドバーのウィジェット内にカスタムフィールドを表示する場合にチェックを付けて下さい。',

    'Display in Main' => 'メインエリアに表示',

    'main' => 'メインエリア',
    'sidebar' => 'サイドバー',

    'Set display position of [_1] field(s) to [_2].' => '[_1]件のカスタムフィールドの表示位置を[_2]に設定しました。',
    'Display Position' => '表示位置',
    'Custom Fields' => 'カスタムフィールド',
);

1;

