
// app/views/shered/_header.html.erb内の<script>内を移動

// 吹き出しトグルの指示
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

// ハートトグルの指示
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

