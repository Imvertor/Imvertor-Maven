function click(event) {

    var mark = event.target;
    while ((mark.className != "b") && (mark.nodeName != "BODY")) {
        mark = mark.parentNode
    }

    var e = mark;
    while ((e.className != "e") && (e.nodeName != "BODY")) {
        e = e.parentNode
    }

    if (mark.childNodes[0].nodeValue == "+") {
        mark.childNodes[0].nodeValue = "-";
        for (var i = 2; i < e.childNodes.length; i++) {
            var name = e.childNodes[i].nodeName;
            if (name != "#text") {
                if (name == "PRE" || name == "SPAN") {
                   window.status = "inline";
                   e.childNodes[i].style.display = "inline";
                } else {
                   e.childNodes[i].style.display = "block";
                }
            }
        }
    } else if (mark.childNodes[0].nodeValue == "-") {
        mark.childNodes[0].nodeValue = "+";
        for (var i = 2; i < e.childNodes.length; i++) {
            if (e.childNodes[i].nodeName != "#text") {
                e.childNodes[i].style.display = "none";
            }
        }
    }
}  
