console.log("games.js が読み込めました");

// ペア完成時の色を定義（左から緑、青、黄、オレンジ、赤）
const COLORS = ['#00C000', '#0000FF', '#c5c500', '#f58500', '#ff0000'];
const TOTAL_PAIRS       = 5;
const CARD_BACK_CLASS   = 'card back';
const CARD_FINISH_CLASS = 'card finish';
const CARD_FRONT_CLASS  = 'card';

const resetGameState = { // 初期値を定義
  cards:     [],         // 生成されたカード要素を格納する配列は、空
  flgFirst:  true,       // 1枚目のカードかどうかを示すフラグ
  cardFirst: null,       // 1枚目にめくられたカードを保持する変数
  countUnit: 0,          // 見つけたペアの数
  currentColorIndex: 0,  // どの色を次に使うかを追跡するためのインデックス
  isLocked:  false       // ゲームのカードが選択できない状態（ロック状態）にされているかどうか
};

let gameState = { ...resetGameState };  // 現在の状態を保持するオブジェクト

const resetGame = () => {  // 初期状態にリセットする定義
  gameState = { ...resetGameState };
};

const shuffleArray = (arr) => {  // フィッシャー–イェーツ法でシャッフル
  // 取り出すarrの中を、末尾から狭める繰り返し
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1)); // 0からiの範囲のランダムなインデックスjを生成
    [arr[i], arr[j]] = [arr[j], arr[i]]; }         // 配列の要素を交換して、シャッフルする
  return arr;
};

const createCardElement = (index, number) => {
  const div = document.createElement('div'); // 新しいdiv要素を作成
  div.className = CARD_BACK_CLASS;  // 初期状態は裏向き
  div.index     = index;
  div.number    = number;
  div.onclick   = handleCardClick;  // クリック時の処理を設定
  return div;
};

const showModal = () => {
  const modal = document.getElementById('modal');
  if (modal) modal.style.display = 'block';
};

const hideModal = () => {
  const modal = document.getElementById('modal');
  if (modal) modal.style.display = 'none';
};

const handlePairMatch = (matchedCard) => {
  gameState.countUnit++;           // 一致したペアのカウントを1増す
  setTimeout(() => {
    matchedCard.className           = CARD_FINISH_CLASS;                   // 完成として表示
    gameState.cardFirst.className   = CARD_FINISH_CLASS;                   // 完成として表示
    matchedCard.style.color         = COLORS[gameState.currentColorIndex]; // 色を設定
    gameState.cardFirst.style.color = COLORS[gameState.currentColorIndex];

    // 次に使用する色のインデックスを更新し、リストの終わりに達したら最初に戻る
    gameState.currentColorIndex   = (gameState.currentColorIndex + 1) % COLORS.length;

    if (gameState.countUnit === TOTAL_PAIRS) {
      setTimeout(showModal, 5000);
    }
    gameState.isLocked = false;
  }, 500);  // ペアなら、0.5秒の速度で文字の色が変わる
};

const handleNoMatch = (unmatchedCard) => {
  setTimeout(() => {
    unmatchedCard.className = CARD_BACK_CLASS;
    unmatchedCard.innerHTML = '';
    gameState.cardFirst.className = CARD_BACK_CLASS;
    gameState.cardFirst.innerHTML = '';
    gameState.cardFirst = null;   // 最初のカードをクリア
    gameState.isLocked  = false;
  }, 900);  // ノーペアなら、0.9秒の速度でカードが伏せられる
};

const handleCardClick = (event) => {
  const div = event.target;  //クリックされたたカードを取得

  // カードがまだ裏向き、ノーペアがあり、ゲームがロックされてない状態かを確認
  if (div.className !== CARD_BACK_CLASS || gameState.countUnit === TOTAL_PAIRS || gameState.isLocked) return;

  div.className = CARD_FRONT_CLASS;
  div.innerHTML = div.number;

  if (gameState.flgFirst) {
    gameState.cardFirst = div;     // 1枚目のカードを保存
    gameState.flgFirst  = false; } // 1枚目のフラグを更新
  else {                           // ２枚目がクリックされたら
    gameState.isLocked = true;
    if (gameState.cardFirst.number === div.number) {
      handlePairMatch(div); }
    else {
      handleNoMatch(div);
    }
    gameState.flgFirst = true; }   // フラグを戻し、次のクリックが可能にする
};

// ページ読み込み時の処理
document.addEventListener("turbo:load", () => {
  resetGame();

  const closeButton = document.querySelector('.close-button');
  if (closeButton) {
    closeButton.addEventListener('click', hideModal); }
  else {
    console.warn('閉じるボタン見つかんない');
  }

  const postsDataElement = document.getElementById("posts-data");
  const panel = document.getElementById('panel');
  if (panel) {
    while (panel.firstChild) {  // 既存のカードを削除
      panel.removeChild(panel.firstChild); } }
  else {
    console.warn('パネル要素がないよー');
    return;
  }

  if (postsDataElement) {
    const POST_ID = postsDataElement.getAttribute("data-post-id");
    console.log("投稿データを取得：", POST_ID);

    // 各投稿データの属性からデータを取得し、配列に入れる
    const aruaruData = ['one', 'two', 'three', 'four', 'five'].map(num =>
      postsDataElement.getAttribute(`data-aruaru-${num}`) );

    // カードの数を2倍にしてシャッフル
    const cardNumbers = shuffleArray([...aruaruData, ...aruaruData]);

    cardNumbers.forEach((number, index) => {
      const card = createCardElement(index, number); // 各データに対してカード要素を作成
      panel.appendChild(card);             // 作成したカード要素を、パネルに差し込み
      gameState.cards.push(card); }); }    // 生成したカードを、カードの配列に追加
  else {
    console.warn('投稿データが見つかんない');
  }
});
