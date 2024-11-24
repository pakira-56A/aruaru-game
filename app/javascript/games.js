console.log("games.js が読み込めました");

// ペア完成時の色を定義（左から緑、青、ピンク、オレンジ、赤）
const colors = ['#21c000', '#008eff', '#ff68fa', '#ff7b0b', '#ff0000'];

let cards = [];             // カード要素を格納する配列
let flgFirst = true;        // 1枚目のカードかどうかを示すフラグ
let cardFirst;              // 1枚目にめくられたカードを保持
let countUnit = 0;          // 見つけたペアの数
let currentColorIndex = 0;  // 現在使用する色のインデックス
let isLocked = false;       // ゲームがロックされているかどうか

// ゲームの状態をリセットする関数
const resetGame = () => {
    cards = [];
    flgFirst = true;
    cardFirst = null;
    countUnit = 0;
    currentColorIndex = 0;
    isLocked = false;
};

// 配列をシャッフルする関数
const shuffle = (arr) => {
    for (let i = arr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
};

// カード要素を作成する関数
const createCard = (index, number) => {
    const div = document.createElement('div');
    div.className = 'card back';
    div.index = index;
    div.number = number;
    div.innerHTML = '';
    div.onclick = turn;
    return div;
};

// モーダルを表示する関数
const showModal = () => {
    const modal = document.getElementById('modal');
    if (modal) modal.style.display = 'block';
};

// モーダルを非表示にする関数
const hideModal = () => {
    const modal = document.getElementById('modal');
    if (modal) modal.style.display = 'none';
};

// ペアが一致した時の処理
const handlePairMatch = (div) => {
    countUnit++;
    setTimeout(() => {
        div.className = 'card finish';
        cardFirst.className = 'card finish';
        div.style.color = colors[currentColorIndex];
        cardFirst.style.color = colors[currentColorIndex];
        currentColorIndex = (currentColorIndex + 1) % colors.length;

        if (countUnit === 5) {
            setTimeout(showModal, 1000); } // 全カードがペアになった1秒後にモーダル表示
        isLocked = false;
    }, 500);  // カードがペアになったら0.5秒の速度で文字の色が変わる
};

// ペアが一致しなかった時の処理
const handleNoMatch = (div) => {
    setTimeout(() => {
        div.className = 'card back';
        div.innerHTML = '';
        cardFirst.className = 'card back';
        cardFirst.innerHTML = '';
        cardFirst = null;
        isLocked = false;
    }, 700);  // 0.7秒の速度でノーペアのカードが伏せられる
};

// カードをクリックした時の処理
const turn = (e) => {
    const div = e.target;
    if (div.className === 'card' || div.className === 'card finish' || countUnit === 5 || isLocked) return;

    div.className = 'card';
    div.innerHTML = div.number;

    if (flgFirst) {
        cardFirst = div;
        flgFirst = false; }
    else {
        isLocked = true;
        if (cardFirst.number == div.number) {
            handlePairMatch(div);}
        else { handleNoMatch(div); }
        flgFirst = true; }
};

// ゲームの開始時に、渡された投稿データを利用
// 下記の""にDOMContentLoadedを書くと、Turboだと発火しちゃうので却下
document.addEventListener("turbo:load", () => {
    resetGame(); // ゲームの状態をリセット

    // モーダルを閉じるボタンの設定
    const closeButton = document.querySelector('.close-button');
    if (closeButton) {
        closeButton.addEventListener('click', hideModal); }
    else { console.warn('閉じるボタンが見つかりませんでした'); }

    // ゲームパネルの取得と初期化
    const postsDataElement = document.getElementById("posts-data");
    const panel = document.getElementById('panel');
    // panelが存在するか確認
    if (panel) {
        // 既存のカードを削除
        while (panel.firstChild) {
            panel.removeChild(panel.firstChild); } }
    else {
        console.warn('パネル要素が見つかりませんでした');
        return; }

    // 投稿データの取得とカードの生成
    if (postsDataElement) {
        const postID = postsDataElement.getAttribute("data-post-id"); // post ID を取得
        console.log("投稿データを取得：", postID);

        // あるある要素のデータを取得
        const aruaruData = ['one', 'two', 'three', 'four', 'five'].map(num =>
            postsDataElement.getAttribute(`data-aruaru-${num}`) );

        // カードデータの配列を作成し、シャッフル
        const arr = shuffle([...aruaruData, ...aruaruData]);

        // カードを生成し、パネルに追加
        arr.forEach((number, index) => {
            const card = createCard(index, number);
            panel.appendChild(card);
            cards.push(card); }); }
    else { console.warn('投稿データが見つかりませんでした'); }
});


// // モーダルの外側をクリックで閉じる（こちらに変更するかもなので、一応残しておきます）
// const modal = document.getElementById('modal');
// if (modal) {
//     modal.addEventListener('click', function(event) {
//         // クリックしたのがモーダルの内容でない場合に閉じる
//         if (event.target === modal) {
//             hideModal(); }
// });}