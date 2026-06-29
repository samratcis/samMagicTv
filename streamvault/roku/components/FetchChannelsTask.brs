Sub Init()
  m.top.functionName = "Run"
End Sub

Sub Run()
  url = m.top.url
  If url = invalid Or url.Trim() = "" Then
    m.top.error = "Catalog URL is empty."
    Return
  End If

  transfer = CreateObject("roUrlTransfer")
  transfer.SetUrl(url)
  transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
  transfer.InitClientCertificates()
  transfer.AddHeader("Accept", "application/json")

  body = transfer.GetToString()
  code = transfer.GetResponseCode()
  If code < 200 Or code >= 300 Then
    m.top.error = "Catalog request failed with HTTP " + code.ToStr() + "."
    Return
  End If

  parsed = ParseJson(body)
  If parsed = invalid Then
    m.top.error = "Catalog response was not valid JSON."
    Return
  End If

  rawItems = ExtractItemArray(parsed)
  If rawItems = invalid Then
    m.top.channels = []
    Return
  End If

  channels = []
  For Each item In rawItems
    channel = NormalizeChannel(item)
    If channel <> invalid Then channels.Push(channel)
  End For

  m.top.channels = channels
End Sub

Function ExtractItemArray(parsed As Dynamic) As Dynamic
  If Type(parsed) = "roArray" Then Return parsed
  If Type(parsed) <> "roAssociativeArray" Then Return invalid

  keys = ["channels", "items", "content", "data"]
  For Each key In keys
    value = parsed[key]
    If value <> invalid And Type(value) = "roArray" Then Return value
  End For

  Return invalid
End Function

Function NormalizeChannel(item As Dynamic) As Dynamic
  If Type(item) <> "roAssociativeArray" Then Return invalid

  url = FirstString(item, ["url", "stream_url", "streamUrl", "playbackUrl", "hls", "src"])
  If url = "" Then Return invalid

  title = FirstString(item, ["name", "title", "channel", "label"])
  If title = "" Then title = url

  Return {
    title: title,
    url: url
  }
End Function

Function FirstString(item As Object, keys As Object) As String
  For Each key In keys
    value = item[key]
    If value <> invalid Then
      text = value.ToStr().Trim()
      If text <> "" Then Return text
    End If
  End For
  Return ""
End Function
