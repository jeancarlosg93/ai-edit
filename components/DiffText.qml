import QtQuick
import qs.Commons

// Renders the segments from `ai-edit diff`: deletions struck through in red,
// insertions in green, line breaks and runs of spaces kept. With
// resultOnly it shows the new text alone, for a result that is mostly new
// (a translation), where red and green would be noise.
Text {
  property var segments: []
  property bool resultOnly: false
  property color deletedColor: Color.urgent
  property color insertedColor: "#a6e3a1"

  textFormat: Text.RichText
  wrapMode: Text.Wrap
  text: {
    var html = ""
    for (var i = 0; i < segments.length; i++) {
      var segment = segments[i]
      if (resultOnly && segment.op === "del") continue
      var body = String(segment.text)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/ {2}/g, " &nbsp;")
        .replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;")
        .replace(/\n/g, "<br>")
      if (resultOnly || segment.op === "equal")
        html += body
      else if (segment.op === "del")
        html += "<span style=\"color:" + deletedColor + "; text-decoration: line-through\">" + body + "</span>"
      else
        html += "<span style=\"color:" + insertedColor + "\">" + body + "</span>"
    }
    return html
  }
}
