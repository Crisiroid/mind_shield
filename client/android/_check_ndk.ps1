$root = 'C:\Users\Crisiroid\AppData\Local\Pub\Cache\hosted\pub.myket.ir'
$names = 'jni','jni_flutter','sqflite_android','just_audio','flutter_local_notifications','permission_handler_android','connectivity_plus','wakelock_plus','audio_session','package_info_plus'
Get-ChildItem $root -Directory | Where-Object { $base = $_.Name.Split('-')[0]; $names -contains $base } | ForEach-Object {
    $d = Join-Path $_.FullName 'android'
    if (Test-Path $d) {
        Get-ChildItem $d -Filter 'build.gradle*' -File | ForEach-Object {
            $m = Select-String -Path $_.FullName -Pattern 'ndkVersion'
            if ($m) {
                foreach ($line in $m) {
                    Write-Output ("{0} :: line {1} :: {2}" -f $_.FullName, $line.LineNumber, $line.Line.Trim())
                }
            }
        }
    }
}
