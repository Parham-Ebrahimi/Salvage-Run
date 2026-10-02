param([switch]$Click,[int]$X,[int]$Y)
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class StudioWindow {
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd,int command);
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd, out Rect rect);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint flags,uint x,uint y,uint data,UIntPtr extra);
}
'@
$studioWindowProcess=Get-Process RobloxStudioBeta | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if(-not $studioWindowProcess){throw 'Current build Studio window not found'}
$studioWindowRect=New-Object StudioWindow+Rect
[StudioWindow]::ShowWindow($studioWindowProcess.MainWindowHandle,9) | Out-Null
[StudioWindow]::GetWindowRect($studioWindowProcess.MainWindowHandle,[ref]$studioWindowRect) | Out-Null
[StudioWindow]::SetForegroundWindow($studioWindowProcess.MainWindowHandle) | Out-Null
if($Click){
 [StudioWindow]::SetCursorPos($studioWindowRect.Left+$X,$studioWindowRect.Top+$Y) | Out-Null
 [StudioWindow]::mouse_event(2,0,0,0,[UIntPtr]::Zero)
 [StudioWindow]::mouse_event(4,0,0,0,[UIntPtr]::Zero)
}else{
 $studioCapture=New-Object System.Drawing.Bitmap ($studioWindowRect.Right-$studioWindowRect.Left),($studioWindowRect.Bottom-$studioWindowRect.Top)
 $studioGraphics=[System.Drawing.Graphics]::FromImage($studioCapture)
 $studioGraphics.CopyFromScreen($studioWindowRect.Left,$studioWindowRect.Top,0,0,$studioCapture.Size)
 $studioCapture.Save((Join-Path $PWD 'tools/studio-window.png'))
 $studioGraphics.Dispose();$studioCapture.Dispose()
}
