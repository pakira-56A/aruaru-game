console.log("loading.js が読み込めました");

document.addEventListener("turbo:load", function() {
    const links = document.querySelectorAll("a[data-loading]");
    const loadingAnimation = document.getElementById("loading"); // id="loading" を格納
    const body = document.querySelector("body");  // <body> 要素を取得し、body 変数に格納

    // links 変数に格納された全ての <a> タグ要素に、クリックイベントリスナーを設定
    links.forEach(link => {
        link.addEventListener("click", function(event) {
            showLoadingAnimation();  });  });

    // AI生成のフォーム送信時のイベントリスナー
    const form = document.getElementById("myForm");
    if (form) {
        form.addEventListener("submit", function(event) { // submitイベントが発火し、その際に指定した関数が実行されるように設定
            event.preventDefault(); // フォーム送信を停止（ページがリロードされずに次の処理が行える）
            showLoadingAnimation(); // ローディングアニメーションを表示す
            this.submit();  }); }   // フォームを送信（thisはイベントリスナー内ではformを指すので、フォームが送信）

    function showLoadingAnimation() {
        // ローディングアニメーションを表示
        // style.display を "flex" に設定し、hidden クラスを削除し、flex クラスを追加することで、ローディングアニメーションを表示
        loadingAnimation.style.display = "flex";
        loadingAnimation.classList.remove("hidden");
        loadingAnimation.classList.add("flex");
        body.classList.add("overflow-hidden"); } // スクロール禁止
});