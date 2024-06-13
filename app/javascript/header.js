
// ページがロードされたときにトグルの初期状態を設定
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('toggle-content1').style.display = 'none';
    document.getElementById('toggle-content2').style.display = 'none';
});

// トグル内の項目をクリックしても、ページ移動させない指示
document.querySelectorAll('a').forEach(function(link) {
    link.addEventListener('click', function(event) {
        event.preventDefault();
        alert("まだできないよ！待っててね🙇‍♀️");
    });
});

// header/toggle-1トグル(トグル1)の指示
document.getElementById('toggle-button1').addEventListener('click', function() {
    let content = document.getElementById('toggle-content1');
        // トグル1を開いてる時に、トグル2は開かない指示
    let content2 = document.getElementById('toggle-content2');
    
    if (content.style.display === 'none' || content.style.display === '') {
        content.style.display = 'block';
        // トグル1を開いてる時に、トグル2は開かない指示
        content2.style.display = 'none';
    } else {
        content.style.display = 'none';
    }
});


// header/toggle-2トグル(トグル2)の指示
document.getElementById('toggle-button2').addEventListener('click', function() {
    let content = document.getElementById('toggle-content2');
        // トグル2を開いてる時に、トグル1は開かない指示
    let content1 = document.getElementById('toggle-content1');
    if (content.style.display === 'none' || content.style.display === '') {
        content.style.display = 'block';
        // トグル2を開いてる時に、トグル1は開かない指示
        content1.style.display = 'none';
    } else {
        content.style.display = 'none';
    }
});
