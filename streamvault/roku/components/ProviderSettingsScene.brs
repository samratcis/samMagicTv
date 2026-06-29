Sub Init()
  m.menu = m.top.FindNode("menu")
  m.statusLabel = m.top.FindNode("statusLabel")
  m.workerUrl = ""
  m.catalogPath = "/api/catalog/content?connectionId=dev&type=live"
  m.directHlsUrl = ""
  m.editingKey = ""

  m.menu.ObserveField("itemSelected", "OnMenuSelected")
  RenderMenu()
  m.menu.SetFocus(true)
End Sub

Sub OnSettingsSet()
  settings = m.top.settings
  If settings = invalid Then Return
  If settings.workerUrl <> invalid Then m.workerUrl = settings.workerUrl
  If settings.catalogPath <> invalid Then m.catalogPath = settings.catalogPath
  If settings.directHlsUrl <> invalid Then m.directHlsUrl = settings.directHlsUrl
  RenderMenu()
End Sub

Sub OnStatusChanged()
  m.statusLabel.text = m.top.status
End Sub

Sub OnMenuSelected(event As Object)
  index = event.GetData()
  If index = 0 Then
    OpenKeyboard("workerUrl", "Cloudflare Worker URL", m.workerUrl)
  Else If index = 1 Then
    OpenKeyboard("catalogPath", "Catalog path or URL", m.catalogPath)
  Else If index = 2 Then
    OpenKeyboard("directHlsUrl", "Direct HLS URL", m.directHlsUrl)
  Else If index = 3 Then
    EmitSettings()
    m.top.status = "Settings saved."
  Else If index = 4 Then
    EmitSettings()
    m.top.loadRequested = true
  Else If index = 5 Then
    EmitSettings()
    m.top.directPlayRequested = true
  End If
End Sub

Sub OpenKeyboard(key As String, title As String, value As String)
  m.editingKey = key
  keyboard = CreateObject("roSGNode", "KeyboardDialog")
  keyboard.title = title
  keyboard.text = value
  keyboard.buttons = ["Save", "Cancel"]
  keyboard.ObserveField("buttonSelected", "OnKeyboardClosed")
  m.top.GetScene().dialog = keyboard
End Sub

Sub OnKeyboardClosed(event As Object)
  buttonIndex = event.GetData()
  dialog = m.top.GetScene().dialog
  If dialog <> invalid And buttonIndex = 0 Then
    If m.editingKey = "workerUrl" Then
      m.workerUrl = dialog.text.Trim()
    Else If m.editingKey = "catalogPath" Then
      m.catalogPath = dialog.text.Trim()
    Else If m.editingKey = "directHlsUrl" Then
      m.directHlsUrl = dialog.text.Trim()
    End If
    RenderMenu()
    EmitSettings()
  End If
  m.top.GetScene().dialog = invalid
  m.menu.SetFocus(true)
End Sub

Sub EmitSettings()
  m.top.settingsChanged = {
    workerUrl: m.workerUrl,
    catalogPath: m.catalogPath,
    directHlsUrl: m.directHlsUrl
  }
End Sub

Sub RenderMenu()
  content = CreateObject("roSGNode", "ContentNode")
  AddMenuRow(content, "Worker URL: " + DisplayValue(m.workerUrl))
  AddMenuRow(content, "Catalog path: " + DisplayValue(m.catalogPath))
  AddMenuRow(content, "Direct HLS URL: " + DisplayValue(m.directHlsUrl))
  AddMenuRow(content, "Save settings")
  AddMenuRow(content, "Load channels")
  AddMenuRow(content, "Play direct HLS")
  m.menu.content = content
End Sub

Sub AddMenuRow(parent As Object, title As String)
  child = parent.CreateChild("ContentNode")
  child.title = title
End Sub

Function DisplayValue(value As String) As String
  If value = invalid Or value.Trim() = "" Then Return "(not set)"
  If Len(value) > 96 Then Return Left(value, 93) + "..."
  Return value
End Function

Function OnKeyEvent(key As String, press As Boolean) As Boolean
  If Not press Then Return false
  Return false
End Function
