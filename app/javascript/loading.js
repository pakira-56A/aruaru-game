console.log("loading.js が読み込めました");

document.addEventListener("turbo:load", function() {
  const links = document.querySelectorAll("a[data-loading]");
  const loadingAnimation = document.getElementById("loading");
  const body = document.querySelector("body");

  function hideLoadingAnimation() {
    loadingAnimation.classList.add("hidden");
    loadingAnimation.classList.remove("flex");  // Flexboxレイアウトが無効
    body.classList.remove("overflow-hidden");   // ページを再スクロールできるようになる
  }

  function showLoadingAnimation() {
    loadingAnimation.classList.remove("hidden");
    loadingAnimation.classList.add("flex");    // Flexboxレイアウトが適応
    body.classList.add("overflow-hidden");     // スクロール禁止
  }

  links.forEach(link => {
    // link 要素(aタグ)にクリックイベント・アニメを表示する設定
    link.addEventListener("click", function() {
      showLoadingAnimation();

      // ゲーム画面へ遷移が完了したら
      window.addEventListener("turbo:render", function() {
        hideLoadingAnimation();  // ローディングアニメーションを非表示にする
      }, { once: true });        // 一度だけ実行させ、同じイベントリスナーが複数回登録されないようにする
    });
  });

  const form = document.getElementById("myForm");
  if (form) {
    // AI生成のフォーム送信時の処理
    form.addEventListener("submit", function(event){
      event.preventDefault(); // フォーム送信を停止し、アニメを表示する隙を与える
      showLoadingAnimation();
      this.submit();
    });
  }
});