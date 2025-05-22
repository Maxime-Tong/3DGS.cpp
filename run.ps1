<#
.SYNOPSIS
    Run 3DGS Viewer with multiple resolutions and datasets.
.DESCRIPTION
    This script runs the 3DGS Viewer executable with various combinations of 
    resolutions and datasets. It automatically loops through all specified
    configurations.
#>

# ===== 可修改的变量 =====
$exePath = "D:\workspace\master\3DGS\HUAWEI\3dgs.cpp\3DGS.cpp\build\apps\viewer\Debug\3dgs_viewer.exe"
$baseSceneConfigDir = "D:\workspace\master\3DGS\HUAWEI\output\seele"

# 定义要测试的分辨率列表
$resolutions = @(
    @{width=1280; height=720},
    @{width=1920; height=1080},
    @{width=2560; height=1440}
)

# 定义要测试的数据集列表
$datasets = @(
    "plant_whitepalm",
    "princess",
    "sand_clock",
    "small_dragon"
)

# ===== 主执行循环 =====
foreach ($dataset in $datasets) {
    $sceneConfigDir = "$baseSceneConfigDir\$dataset"
    $camerasJson = "$sceneConfigDir\cameras_sorted.json"
    $pointCloudPly = "$sceneConfigDir\point_cloud\iteration_30000\point_cloud.ply"
    
    foreach ($res in $resolutions) {
        $width = $res.width
        $height = $res.height
        $output_path = "output\$dataset\$($res.width)_$($res.height)"
        
        Write-Host "`n===== 正在处理: 数据集=$dataset, 分辨率=${width}x${height} ====="
        Write-Host "执行命令: $exePath --width $width --height $height -c $sceneConfigDir --output_path $output_path --camera_path $camerasJson $pointCloudPly"
        
        # 执行命令
        & $exePath --width $width --height $height -c $sceneConfigDir --output_path $output_path --camera_path $camerasJson $pointCloudPly
        # & $exePath --width $width --height $height --output_path $output_path --camera_path $camerasJson $pointCloudPly
        
        # 可选: 添加延迟以防止快速连续启动
        Start-Sleep -Seconds 2
    }
}
