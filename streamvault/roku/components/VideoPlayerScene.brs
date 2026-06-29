Sub Init()
  m.video = m.top.FindNode("video")
  m.statusLabel = m.top.FindNode("statusLabel")
  m.video.ObserveField("state", "OnVideoStateChanged")
End Sub

Sub OnVideoChanged()
  url = m.top.videoUrl
  If url = invalid Or url.Trim() = "" Then Return

  title = m.top.videoTitle
  If title = invalid Or title.Trim() = "" Then title = "StreamVault"

  content = CreateObject("roSGNode", "ContentNode")
  content.title = title
  content.url = url.Trim()
  content.streamFormat = GuessStreamFormat(url)

  m.statusLabel.text = "Loading " + title
  m.video.content = content
  m.video.control = "play"
  m.video.SetFocus(true)
End Sub

Sub OnVideoStateChanged()
  state = m.video.state
  If state = "error" Then
    m.statusLabel.text = "Playback error. Check that the URL is reachable by Roku."
  Else If state = "finished" Then
    m.top.closeRequested = true
  Else
    m.statusLabel.text = ""
  End If
End Sub

Function GuessStreamFormat(url As String) As String
  lower = LCase(url)
  If Instr(1, lower, ".m3u8") > 0 Then Return "hls"
  If Instr(1, lower, ".mp4") > 0 Then Return "mp4"
  Return "hls"
End Function

Function OnKeyEvent(key As String, press As Boolean) As Boolean
  If Not press Then Return false
  If key = "back" Then
    m.video.control = "stop"
    m.top.closeRequested = true
    Return true
  End If
  Return false
End Function
