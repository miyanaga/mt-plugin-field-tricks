# FieldTricks for Movable Type

使いやすいCMSを構築するため、記事やウェブページの編集画面の動作をカスタマイズできます。

## ブログやウェブサイトの投稿設定に項目を追加

動作をカスタマイズするには、ブログやウェブサイトの設定-投稿を開いて下さい。

## タイトルと本文の表示変更

CMSとしての利用時には、本文や追記を利用しないことがあります。

しかし標準のMovable Typeでは、記事の編集画面でタイトルと本文を非表示にしたり、ドラッグ＆ドロップにより表示位置を変更することができません。

このプラグインの次のオプションを指定することで、それらのカスタマイズを可能にします。

* タイトルと本文エディタの非表示を可能にします
* タイトルと本文エディタの並べ替えを可能にします

## ライター・編集者への表示オプション操作禁止

ブログ記事の編集画面では、表示オプションによりカスタムフィールドの表示および非表示を選択したり、ドラッグ＆ドロップにより順番を入れ替えることが可能ですが、初心者にはわかりにくい操作です。

また、記事の内容を記述したいだけのユーザーにとっては、必要な項目が予め表示されている方がわかりやすいインターフェースと言えるでしょう。

* 許可されたユーザーにのみ表示オプションの変更を許可し、それ以外のユーザーに適用します

この設定項目は、ブログやウェブサイトの管理権限を持ったユーザーにのみ、表示オプションによる表示非表示の切り替えと、ドラッグ＆ドロップによる順番の変更を許可します。

ライターや編集者は、管理者が配置した項目が最初から表示され、それを変更することができなくなります。

この表示オプションの編集許可のため、`表示オプションの編集`という新たな権限が追加されます。これをロールに追加・削除することで細かな設定が可能です。

## フィールドの並び順の記事ごとの保存と呼び出し

編集画面で並べたフィールドの順番で、実際のページ上も表示を行いたいと思ったことはありませんか。

* それぞれの記事またはウェブページごとにフィールドの並び順を保存します

このオプションは、表示オプションの設定値を、記事ごとに保存してテンプレートタグでその並びを取得することができます。

## サイドバーへのカスタムフィールド表示

metaタグの値や一覧上のサムネイルなど、記事ページには表示されないメタデータのような情報は、メインエリアではなく、サイドバーに表示させると役割が明確になります。

カスタムフィールドの編集画面に、表示位置を指定するオプションが追加されます。

また、カスタムフィールドの一覧でも表示オプションから表示位置を選択して一覧で確認することができ、選択したカスタムフィールドの表示位置を一括で変更することもできます。

## カスタムフィールドの連番複製

カスタムフィールドの一覧で、選択した複数のカスタムフィールドの末尾に連番を付加し、複製することが可能です。

同じようなカスタムフィールドを複数、用意するときに便利な機能です。

## カスタムフィールドの他のブログへの複製

カスタムフィールドの一覧で、選択した複数のカスタムフィールドを、他のブログやウェブサイトにまとめて複製することが可能です。

あるブログやウェブサイトで作成したカスタムフィールドを、他のブログやウェブサイトでも利用したいときに便利です。
