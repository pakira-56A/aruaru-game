console.log("games.js が読み込めました");

var cards = [];         // div要素を格納
var flgFirst = true;    // 1枚目かどうかのフラグ   1枚目: true   2枚目: false
var cardFirst;          // 1枚目のカードを格納
var countUnit = 0;      // そろえた枚数


// ゲームの開始時に、渡された投稿データを利用
// 下記の""にDOMContentLoadedを書くと、Turboだと発火しちゃうので却下
document.addEventListener("turbo:load", () => {
    const postsDataElement = document.getElementById("posts-data");

    // 投稿データが存在するか確認
    if (postsDataElement) {
        const postID = postsDataElement.getAttribute("data-post-id"); // post ID を取得
        const aruaruOne = postsDataElement.getAttribute("data-aruaru-one");
        const aruaruTwo = postsDataElement.getAttribute("data-aruaru-two");
        const aruaruThree = postsDataElement.getAttribute("data-aruaru-three");
        const aruaruFour = postsDataElement.getAttribute("data-aruaru-four");
        const aruaruFive = postsDataElement.getAttribute("data-aruaru-five");

        console.log("投稿データを取得しました");

        // カードの配列をデータで更新
        var arr = [aruaruOne, aruaruTwo, aruaruThree, aruaruFour, aruaruFive];
        arr = arr.concat(arr); // カードをペアにして2倍にする
        shuffle(arr); // シャッフル

        var panel = document.getElementById('panel');

        // div要素作成
        for (let i = 0; i < 10; i++) {
            var div = document.createElement('div');
            div.className = 'card back';
            div.index = i;
            div.number = arr[i];  // カードの内容にデータを設定
            div.innerHTML = '';
            div.onclick = turn;
            panel.appendChild(div);
            cards.push(div); }
    }
    else { console.warn('投稿データが見つかりませんでした'); }
});

// シャッフル用関数
function shuffle(arr) {
    var n = arr.length;
    var temp, i;
    while (n) {
        i = Math.floor(Math.random() * n--);
        temp = arr[n];
        arr[n] = arr[i];
        arr[i] = temp; }
    return arr;
}

// クリック時の処理
function turn(e) {
    var div = e.target;

    // カードがすでに裏返されてるか、ゲームが終了してる場合は return
    if (div.className === 'card' || div.className === 'card finish' || countUnit === 5) return;

    // カードを表にする
    div.className = 'card';
    div.innerHTML = div.number;

    // 1枚目の処理
    if (flgFirst) { cardFirst = div;
                    flgFirst = false; }
    // 2枚目の処理
    else {
		    // 数字が1枚目と一致する場合
        if (cardFirst.number == div.number) {
            countUnit++;
            setTimeout(function () {
                div.className = 'card finish';
                cardFirst.className = 'card finish';

                if (countUnit == 5) {
                    // ゲーム終了
                    setTimeout(function () {
                        alert('界隈探求クリア！どう思った〜？');
                    }, 500);   //　　0.5秒待って次の処理
                } }, 300); }
        else {   // 一致しない場合
            setTimeout(function () {
                div.className = 'card back';
                div.innerHTML = '';
                cardFirst.className = 'card back';
                cardFirst.innerHTML = '';
                cardFirst = null; }, 700); }
        flgFirst = true;
    }
}