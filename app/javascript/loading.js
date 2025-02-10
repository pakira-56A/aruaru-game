console.log("loading.js が読み込めました");

document.addEventListener("turbo:load", function() {
  const links = document.querySelectorAll("a[data-loading]");
  const loadingAnimation = document.getElementById("loading");
  const body = document.querySelector("body");

  function hideLoadingAnimation() {
    loadingAnimation.style.display = "none";
    loadingAnimation.classList.remove("flex");
    loadingAnimation.classList.add("hidden");
    body.classList.remove("overflow-hidden"); }

  // links 変数に格納された全ての <a> タグ要素に、クリックイベントリスナーを設定
  links.forEach(link => {
    link.addEventListener("click", function(event) {
      showLoadingAnimation();
      // ゲーム画面へ遷移が完了したら、ローディングアニメーションを非表示にする
      window.addEventListener("turbo:render", function() {
        hideLoadingAnimation(); });  }); });

  // AI生成のフォーム送信時のイベントリスナー
  const form = document.getElementById("myForm");
  if (form) {
    form.addEventListener("submit", function(event) { // submitイベントが発火し、その際に指定した関数が実行されるように設定
      event.preventDefault(); // フォーム送信を停止（ページがリロードされずに次の処理が行える）
      showLoadingAnimation();
      this.submit();  }); }   // フォームを送信（thisはイベントリスナー内ではformを指すので、フォームが送信）

  function showLoadingAnimation() {
    loadingAnimation.style.display = "flex";
    loadingAnimation.classList.remove("hidden");
    loadingAnimation.classList.add("flex");
    body.classList.add("overflow-hidden"); } // スクロール禁止
});