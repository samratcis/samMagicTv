Sub Init()
  m.list = m.top.FindNode("list")
  m.statusLabel = m.top.FindNode("statusLabel")
  m.channels = []
  m.list.ObserveField("itemSelected", "OnItemSelected")
  RenderList()
  m.list.SetFocus(true)
End Sub

Sub OnChannelsChanged()
  channels = m.top.channels
  If channels = invalid Then
    m.channels = []
  Else
    m.channels = channels
  End If
  RenderList()
End Sub

Sub OnStatusChanged()
  m.statusLabel.text = m.top.status
End Sub

Sub OnItemSelected(event As Object)
  index = event.GetData()
  If index = 0 Then
    m.top.reloadRequested = true
    Return
  Else If index = 1 Then
    m.top.backRequested = true
    Return
  End If

  channelIndex = index - 2
  If channelIndex >= 0 And channelIndex < m.channels.Count() Then
    m.top.playRequested = m.channels[channelIndex]
  End If
End Sub

Sub RenderList()
  content = CreateObject("roSGNode", "ContentNode")
  AddRow(content, "Reload channels")
  AddRow(content, "Back to provider settings")

  For Each channel In m.channels
    title = "(untitled channel)"
    If channel.title <> invalid And channel.title <> "" Then title = channel.title
    AddRow(content, title)
  End For

  m.list.content = content
End Sub

Sub AddRow(parent As Object, title As String)
  child = parent.CreateChild("ContentNode")
  child.title = title
End Sub

Function OnKeyEvent(key As String, press As Boolean) As Boolean
  If Not press Then Return false
  If key = "back" Then
    m.top.backRequested = true
    Return true
  End If
  Return false
End Function
