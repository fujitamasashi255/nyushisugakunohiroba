# サービス概要
![ogp](/app/assets/images/ogp.png)
大学入試の数学問題を研究・活用したい人が、問題を効率的に整理、検索したり、他のユーザーと問題について情報交換できるアプリケーションです。

URL：https://www.nyushisugakunohiroba.com

# 主な機能
### 問題検索
- 問題を様々な条件で絞り込み・並び替えができるようにしました。その際、検索条件・結果がわかりやすく表示されます。

|![image](https://user-images.githubusercontent.com/88495850/184810304-ba4e099d-2473-46ea-8a93-c9483803d579.png)|![image](https://user-images.githubusercontent.com/88495850/184809499-0502d040-8a74-45b5-b60d-1d635dcee593.png)|
|:------------------:|:------------------:|
|検索フォームと、検索条件・結果の表示|並び替えと問題一覧|

- タグ検索の際、「出題年」「大学」「単元」で絞り込まれた問題に全ユーザーが解答作成時につけたタグの一覧が提案されるようにし、検索が楽しくなるようにしました。

|![image](https://user-images.githubusercontent.com/88495850/184809621-956ae446-a45a-422a-9613-b25dca3c526a.png)|
|:------------------:|
|検索時のタグの提案|

### 解答の作成・共有

- ポイントとタグを作成できるようにし、後述する問題・解答の分類がしやすくなるようにしました。

|![68747470733a2f2f71696974612d696d6167652d73746f72652e73332e61702d6e6f727468656173742d312e616d617a6f6e6177732e636f6d2f302f323531393137332f36616131626333662d356133642d643131342d663436382d3739633339643032323664362e676966](https://user-images.githubusercontent.com/88495850/184810094-1c563847-8bf1-4a37-8344-2374aa07f1df.gif)|![image](https://user-images.githubusercontent.com/88495850/184809675-2bf6ee92-8d0b-4620-b1b7-ca0389027870.png)|
|:----:|:------:|
|ポイント作成では、MathJax、ActionTextを用いて数式を含む文章が簡単に作成できます。|タグ入力の際、解答作成ユーザーが同じ単元の問題につけたタグを提案することで、問題・解答の分類を手助けします。|

- 解答はファイル登録、TeXで作成できます。



|![68747470733a2f2f71696974612d696d6167652d73746f72652e73332e61702d6e6f727468656173742d312e616d617a6f6e6177732e636f6d2f302f323531393137332f32633336323763612d626637352d653238392d393733332d3839616461656563653733612e676966](https://user-images.githubusercontent.com/88495850/184810515-a8060661-058f-4228-9079-d582cc2bb3d6.gif)|
|:--:|
|ファイル登録は3つまででき、それらを任意の順番に並べ替えられます。|

|![image](https://user-images.githubusercontent.com/88495850/184810700-99240e3b-2dbf-4745-aef8-665ff267216b.png)|
|:----:|
|TeXで解答を作成することもできます。|

- 解答に対していいね、コメント、twitter共有ができるようにすることで、ユーザー同士の交流ができます。

|![image](https://user-images.githubusercontent.com/88495850/184810771-177db51b-fe8c-4b21-8fa0-a4a1bc9b2fcb.png)|
|:--:|
|twitter共有時には、ツイートに問題文の画像を表示し、twitterから本サービスに来ていただけるようにしました。|


### 解答の検索
各ユーザーが、自分の作成した解答から検索できます。

- 機能は問題検索とほとんど同じですが、並び替え機能は以下のように異なるものにしました。

|![image](https://user-images.githubusercontent.com/88495850/184810803-df0ad8c0-c77a-4373-be62-e7a6d9103e89.png)|
|:--:|
|様々な並び替えを行うことができます。解答一覧にはポイント、タグ、問題文が表示されるようにすることで、検索結果から問題・解答が探しやすくなるようにしました。|

# 工夫したこと
### 数式を含む文書を作成する機能
本サービスでは、gem rails-latex を利用して、解答作成をTeXで行えるようにしました。また、JSライブラリ MathJax を利用して、解答のポイント、解答へのコメントに数式を含めることができるようにしました。実装の詳細を記事にしました。
- [【Ruby on Rails】rails-latexを利用してPDFを作成](https://qiita.com/ma__sa/items/34f591604c65687a0110)
- [【Ruby on Rails】ActionTextとMathJax 3.2で数式を表示できる簡易エディターを実装する](https://qiita.com/ma__sa/items/a48cdaac7f6303acad86)

# 使用技術
### システム構成図
![システム構成図 drawio](https://user-images.githubusercontent.com/88495850/184808579-60e639e0-5c22-4c68-b054-83299dc86de8.png)

### バックエンド
- Ruby 3.1.1
- Ruby on Rails 6.1.5

### 主なGem
- rails-latex
- pagy
- Sorcery
- acts-as-taggable-on
- rubocop

### フロントエンド
HTML/SCSS/JavaScript(JQuery)

### 主なフロントエンドライブラリ
- BootStrap
- MathJax
- Tagify
- browser-image-compression


# ER図
![MacBook Pro 14_ - 2 (1)](https://user-images.githubusercontent.com/88495850/182025152-b8315ae6-b2c7-4559-9fae-5656a4bbac8b.png)

以下のテーブルは省略しています。
- active_storage_attachments
- active_storage_blobs
- active_storage_variant_records
- action_text_rich_texts

# サービス作成で得た知見のいくつかを記事にしました
- [【Ruby on Rails】検索結果のレコードを並び替える](https://qiita.com/ma__sa/items/35d7cff12c5a4e4b57ba)
- [【Ruby on Rails】rails-latexを利用してPDFを作成](https://qiita.com/ma__sa/items/34f591604c65687a0110)
- [【Ruby on Rails】ActionTextとMathJax 3.2で数式を表示できる簡易エディターを実装する](https://qiita.com/ma__sa/items/a48cdaac7f6303acad86)
