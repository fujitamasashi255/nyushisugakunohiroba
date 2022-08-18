document.addEventListener("DOMContentLoaded", function(){
  const likeContainers = document.querySelectorAll(".like-container");
  likeContainers.forEach(container => container.addEventListener("click", toggleLikeButton));

});

function toggleLikeButton(e){
  var button = e.target.closest("button");
  if(button){
    var icon = button.firstChild.firstChild;
    // likeボタンを押したら
    if (icon.classList.contains('bi-heart')){
      unlikeToLike(icon);
    }
    // unlikeボタンを押したら
    else if (icon.classList.contains('bi-heart-fill')){
      likeToUnlike(icon);
    }
  }
}

// likeボタンを押した際の処理
function unlikeToLike(icon) {
  const buttonContainer = icon.parentNode.parentNode;
  var path = buttonContainer.dataset.path;
  buttonContainer.dataset.path = "";
  if(path){
    // アイコンをunlikeからlikeに変更し、いいね数を1増加させる
    unlikeToLikeOfIcon(icon)
    // ajax送信
    $.ajax({
      url: path,
      type: 'POST',
      dataType: 'json',
      timeout: 5000,
    })
    .done(function(data) {
      // 通信成功時、ボタンにunlikeのパスをセット
      buttonContainer.dataset.path = data.destroy_path;
    })
    .fail(function() {
      // 通信失敗時、アイコンをlikeからunlikeに変更し、いいね数を1減少させる
      likeToUnlikeOfIcon(icon);
      buttonContainer.dataset.path = path;
    });
  }
}

// unlikeボタンを押した際の処理
function likeToUnlike(icon) {
  const buttonContainer = icon.parentNode.parentNode;
  var path = buttonContainer.dataset.path;
  buttonContainer.dataset.path = "";
  if(path){
    // アイコンをlikeからunlikeに変更し、いいね数を1減少させる
    likeToUnlikeOfIcon(icon);
    // ajax送信
    $.ajax({
      url: path,
      type: 'DELETE',
      dataType: 'json',
      timeout: 5000,
    })
    .done(function(data) {
      // 通信成功時、ボタンにlikeのパスをセット
      buttonContainer.dataset.path = data.create_path;
    })
    .fail(function() {
      // 通信失敗時、アイコンをunlikeからlikeに変更し、いいね数を1増加させる
      unlikeToLikeOfIcon(icon)
      buttonContainer.dataset.path = path;
    });
  }
}

// アイコンをlike状態からunlike状態に変更し、いいね数を1減少させる
function likeToUnlikeOfIcon(icon) {
  icon.classList.remove('bi-heart-fill');
  icon.classList.add('bi-heart');
  icon.parentNode.classList.add('like-button');
  icon.parentNode.classList.remove('unlike-button');
  var likesCount = Number(icon.nextSibling.textContent);
  icon.nextSibling.textContent = likesCount-1 ;
}

// アイコンをunlike状態からlike状態に変更し、いいね数を1増加させる
function unlikeToLikeOfIcon(icon) {
  icon.classList.remove('bi-heart');
  icon.classList.add('bi-heart-fill');
  icon.parentNode.classList.remove('like-button');
  icon.parentNode.classList.add('unlike-button');
  var likesCount = Number(icon.nextSibling.textContent);
  icon.nextSibling.textContent = likesCount+1 ;
}
