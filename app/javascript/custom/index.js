//document.getElementById('canvas-original').addEventListener('click', printPosition)

function getPosition(e) {
  var rect = e.target.getBoundingClientRect();
  var x = e.clientX - rect.left;
  var y = e.clientY - rect.top;
  return {
    x,
    y
  }
}

function printPosition(e) {
  var position = getPosition(e);
  document.getElementById('position').value = 'X: ' + position.x + ' Y: ' + position.y;
}

$(function() {
    $("#canvas-original").click(function(e) {

      var offset = $(this).offset();
      var relativeX = (e.pageX - offset.left);
      var relativeY = (e.pageY - offset.top);

      alert("X: " + relativeX + "  Y: " + relativeY);

    });
});
