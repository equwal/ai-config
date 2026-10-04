param([string]$Title='AI done',[string]$Msg='Turn finished')
# Windows toast via WinRT (no module needed); falls back to a balloon.
try {
  [void][Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime]
  [void][Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom.XmlDocument,ContentType=WindowsRuntime]
  $x=New-Object Windows.Data.Xml.Dom.XmlDocument
  $x.LoadXml("<toast><visual><binding template='ToastGeneric'><text>$([Security.SecurityElement]::Escape($Title))</text><text>$([Security.SecurityElement]::Escape($Msg))</text></binding></visual></toast>")
  $id='{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
  [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($id).Show([Windows.UI.Notifications.ToastNotification]::new($x))
} catch {
  Add-Type -AssemblyName System.Windows.Forms,System.Drawing
  $n=New-Object System.Windows.Forms.NotifyIcon
  $n.Icon=[System.Drawing.SystemIcons]::Information; $n.Visible=$true
  $n.ShowBalloonTip(5000,$Title,$Msg,'Info'); Start-Sleep 6; $n.Dispose()
}
exit 0
