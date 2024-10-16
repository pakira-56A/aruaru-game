
// ページがロードされたときにトグルの初期状態を設定
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('toggle-area').style.display = 'none';
});

// トグル内の項目をクリックしても、ページ移動させない指示
document.querySelectorAll('a').forEach(function(link) {
    link.addEventListener('click', function(event) {
        event.preventDefault();
        alert("まだできないよ！待っててね🙇‍♀️");
    });
});

// トグルボタンを押すと、メニューが表示/非表示
document.getElementById('toggle-button').addEventListener('click', function() {
    let content = document.getElementById('toggle-area');
    // 表示状態を確認
    if (content.style.display === 'none' || content.style.display === '') {
        // 表示されていなければ表示
        content.style.display = 'block';
    } else {
        // 表示されていれば非表示
        content.style.display = 'none';
    }
});
