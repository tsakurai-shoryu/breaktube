var tag = document.createElement('script');

tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

var player;
function onYouTubeIframeAPIReady() {
  player = new YT.Player('player', {
    height: '360',
    width: '640',
    events: {
      'onReady': onPlayerReady,
      'onStateChange': onPlayerStateChange
    }
  });
}

function onPlayerReady(event) {
  var source = new EventSource('subscribe');
  source.addEventListener('open', function (event) {
    console.log("open", event);
  });
  source.addEventListener('error', function (event) {
    console.log("error", event);
    if(event.currentTarget.readyState == EventSource.CLOSED) {
      console.log("closed");
      setTimeout(function() { window.location.reload() }, 5*60*1000)
    }
  });
  source.addEventListener('message', function (event) {
    console.log(event);
    var params = JSON.parse(event.data);
    switch(params.type) {
      case "count":
        cu.innerText = params.count;
        break;
      case "select":
        if(player.getVideoData().video_id != params.videoid) {
          player.loadVideoById(params.videoid);
        }
        break;
      case "force":
        nextVideo();
        break;
      }
  });
}

function onPlayerStateChange(event) {
  var status = event.data;

  console.log(status);
  if ( status == '0') {
    nextVideo();
  }
}
function nextVideo() {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', '/next?videoid=' + player.getVideoData().video_id);
  xhr.onreadystatechange = function() {
    if(xhr.readyState === 4 && xhr.status === 200) {
      console.log(xhr.responseText);
      if(xhr.responseText !== "") {
        player.loadVideoById({videoId: xhr.responseText, startSeconds: 0});
      }
      player.playVideoAt();
    }
  }
  xhr.send();
}
function stopVideo() {
  player.stopVideo();
}
