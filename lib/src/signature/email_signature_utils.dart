
class EmailSigantureUtils {

  static const String jsFunctionHandleSignature = '''
    function insertSignature(signature) {
      var nodeSignature = document.getElementsByClassName('tmail-signature');
      if (nodeSignature.length <= 0) {
        var nodeEditor = document.getElementById('editor');
        var tagTop = document.createElement('br');
        tagTop.setAttribute('class', 'tmail-break-tag');
        nodeEditor.appendChild(tagTop);
        var divSignature = document.createElement('div');
        divSignature.setAttribute('class', 'tmail-signature');
        divSignature.innerHTML = signature;
        nodeEditor.appendChild(divSignature);
        var tagBottom = document.createElement('br');
        tagBottom.setAttribute('class', 'tmail-break-tag');
        nodeEditor.appendChild(tagBottom);
      } else {
        nodeSignature[0].innerHTML = signature;
      }
    }
  
    function removeSignature() {
      var nodeSignature = document.getElementsByClassName('tmail-signature');
      if (nodeSignature.length > 0) {
        nodeSignature[0].remove();
      }
      document.querySelectorAll(".tmail-break-tag").forEach(el => el.remove());
    }
  ''';

}