Sub Main()
  screen = CreateObject("roSGScreen")
  port = CreateObject("roMessagePort")
  screen.SetMessagePort(port)

  scene = screen.CreateScene("MainScene")
  screen.Show()

  While true
    msg = Wait(0, port)
    If Type(msg) = "roSGScreenEvent" And msg.IsScreenClosed() Then
      Exit While
    End If
  End While
End Sub
