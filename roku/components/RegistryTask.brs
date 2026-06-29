Sub Init()
  m.top.functionName = "Run"
End Sub

Sub Run()
  section = CreateObject("roRegistrySection", "StreamVault")

  If m.top.mode = "save" Then
    settings = m.top.settings
    If settings <> invalid Then
      section.Write("workerUrl", SafeString(settings.workerUrl))
      section.Write("catalogPath", SafeString(settings.catalogPath))
      section.Write("directHlsUrl", SafeString(settings.directHlsUrl))
      section.Flush()
    End If
    m.top.settings = settings
    Return
  End If

  m.top.settings = {
    workerUrl: SafeString(section.Read("workerUrl")),
    catalogPath: SafeString(section.Read("catalogPath")),
    directHlsUrl: SafeString(section.Read("directHlsUrl"))
  }
End Sub

Function SafeString(value As Dynamic) As String
  If value = invalid Then Return ""
  Return value.ToStr()
End Function
