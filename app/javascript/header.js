
// ページがロードされたときにメニューの初期状態を設定
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('menus-area').style.display = 'none';
});

// メニューボタンを押すと、メニューが表示/非表示
document.getElementById('menus-button').addEventListener('click', function() {
    let content = document.getElementById('menus-area');
    // 表示状態を確認
    if (content.style.display === 'none' || content.style.display === '') {
        // 表示されていなければ表示
        content.style.display = 'block';
    } else {
        // 表示されていれば非表示
        content.style.display = 'none';
    }
});
