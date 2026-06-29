Sub Init()
  m.settingsView = m.top.FindNode("settingsView")
  m.channelView = m.top.FindNode("channelView")
  m.playerView = m.top.FindNode("playerView")

  m.settings = {
    workerUrl: "",
    catalogPath: "/api/catalog/content?connectionId=dev&type=live",
    directHlsUrl: ""
  }

  m.settingsView.ObserveField("settingsChanged", "OnSettingsChanged")
  m.settingsView.ObserveField("loadRequested", "OnLoadRequested")
  m.settingsView.ObserveField("directPlayRequested", "OnDirectPlayRequested")
  m.channelView.ObserveField("backRequested", "OnBackToSettings")
  m.channelView.ObserveField("reloadRequested", "OnLoadRequested")
  m.channelView.ObserveField("playRequested", "OnChannelPlayRequested")
  m.playerView.ObserveField("closeRequested", "OnClosePlayer")

  LoadSettings()
End Sub

Sub LoadSettings()
  task = CreateObject("roSGNode", "RegistryTask")
  task.mode = "load"
  task.ObserveField("settings", "OnSettingsLoaded")
  task.control = "RUN"
End Sub

Sub OnSettingsLoaded(event As Object)
  loaded = event.GetData()
  If loaded <> invalid Then
    If IsNonEmptyString(loaded.workerUrl) Then m.settings.workerUrl = loaded.workerUrl
    If IsNonEmptyString(loaded.catalogPath) Then m.settings.catalogPath = loaded.catalogPath
    If IsNonEmptyString(loaded.directHlsUrl) Then m.settings.directHlsUrl = loaded.directHlsUrl
  End If

  m.settingsView.settings = m.settings
  ShowSettings()
End Sub

Sub OnSettingsChanged(event As Object)
  nextSettings = event.GetData()
  If nextSettings = invalid Then Return

  m.settings = {
    workerUrl: NormalizeWorkerUrl(nextSettings.workerUrl),
    catalogPath: NormalizeCatalogPath(nextSettings.catalogPath),
    directHlsUrl: TrimString(nextSettings.directHlsUrl)
  }

  m.settingsView.settings = m.settings

  task = CreateObject("roSGNode", "RegistryTask")
  task.mode = "save"
  task.settings = m.settings
  task.control = "RUN"
End Sub

Sub OnLoadRequested()
  If Not IsNonEmptyString(m.settings.workerUrl) And Not StartsWithHttp(m.settings.catalogPath) Then
    m.settingsView.status = "Enter a Worker URL before loading channels."
    ShowSettings()
    Return
  End If

  fetchUrl = BuildCatalogUrl(m.settings.workerUrl, m.settings.catalogPath)
  m.channelView.status = "Loading " + fetchUrl
  m.channelView.channels = []
  ShowChannels()

  task = CreateObject("roSGNode", "FetchChannelsTask")
  task.url = fetchUrl
  task.ObserveField("channels", "OnChannelsLoaded")
  task.ObserveField("error", "OnChannelsError")
  task.control = "RUN"
End Sub

Sub OnChannelsLoaded(event As Object)
  channels = event.GetData()
  m.channelView.channels = channels
  If channels = invalid Or channels.Count() = 0 Then
    m.channelView.status = "No playable channels found in catalog response."
  Else
    m.channelView.status = channels.Count().ToStr() + " channels loaded."
  End If
End Sub

Sub OnChannelsError(event As Object)
  message = event.GetData()
  If Not IsNonEmptyString(message) Then message = "Could not load channels."
  m.channelView.status = message
End Sub

Sub OnDirectPlayRequested()
  If IsNonEmptyString(m.settings.directHlsUrl) Then
    PlayVideo(m.settings.directHlsUrl, "Direct HLS")
  Else
    m.settingsView.status = "Enter a direct HLS URL first."
  End If
End Sub

Sub OnChannelPlayRequested(event As Object)
  item = event.GetData()
  If item = invalid Then Return
  If IsNonEmptyString(item.url) Then
    title = "StreamVault"
    If IsNonEmptyString(item.title) Then title = item.title
    PlayVideo(item.url, title)
  End If
End Sub

Sub PlayVideo(url As String, title As String)
  m.playerView.videoUrl = url
  m.playerView.videoTitle = title
  ShowPlayer()
End Sub

Sub OnClosePlayer()
  ShowChannels()
End Sub

Sub OnBackToSettings()
  ShowSettings()
End Sub

Sub ShowSettings()
  m.settingsView.visible = true
  m.channelView.visible = false
  m.playerView.visible = false
  m.settingsView.SetFocus(true)
End Sub

Sub ShowChannels()
  m.settingsView.visible = false
  m.channelView.visible = true
  m.playerView.visible = false
  m.channelView.SetFocus(true)
End Sub

Sub ShowPlayer()
  m.settingsView.visible = false
  m.channelView.visible = false
  m.playerView.visible = true
  m.playerView.SetFocus(true)
End Sub

Function BuildCatalogUrl(workerUrl As String, catalogPath As String) As String
  path = NormalizeCatalogPath(catalogPath)
  If StartsWithHttp(path) Then Return path
  base = NormalizeWorkerUrl(workerUrl)
  Return base + path
End Function

Function NormalizeWorkerUrl(value As Dynamic) As String
  text = TrimString(value)
  While Len(text) > 0 And Right(text, 1) = "/"
    text = Left(text, Len(text) - 1)
  End While
  Return text
End Function

Function NormalizeCatalogPath(value As Dynamic) As String
  text = TrimString(value)
  If text = "" Then text = "/api/catalog/content?connectionId=dev&type=live"
  If StartsWithHttp(text) Then Return text
  If Left(text, 1) <> "/" Then text = "/" + text
  Return text
End Function

Function TrimString(value As Dynamic) As String
  If value = invalid Then Return ""
  Return value.ToStr().Trim()
End Function

Function IsNonEmptyString(value As Dynamic) As Boolean
  Return value <> invalid And Len(value.ToStr().Trim()) > 0
End Function

Function StartsWithHttp(value As Dynamic) As Boolean
  If value = invalid Then Return false
  lower = LCase(value.ToStr())
  Return Left(lower, 7) = "http://" Or Left(lower, 8) = "https://"
End Function
