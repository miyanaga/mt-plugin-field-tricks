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
);

1;

