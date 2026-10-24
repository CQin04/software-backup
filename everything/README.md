# Everything 文件搜索与MCP备份

Everything是voidtools提供的Windows文件名搜索工具。本目录保存用户已收录的三种64位多语言发行包，以及可复用的MCP接入包。三个发行包均为1.4.1.1032，实测SHA256与官方版本摘要一致，未修改二进制内容。

## 三个下载包怎么选

| 类型 | 备份文件 | 大小（字节） | 适用情况 | 此MCP可用 |
| --- | --- | ---: | --- | --- |
| 64位标准安装版 | [Everything-1.4.1.1032.x64-Setup.exe](installers/Everything-1.4.1.1032.x64-Setup.exe) | 1,998,736 | 日常使用推荐，有安装向导，可安装索引服务 | 是 |
| 64位便携版 | [Everything-1.4.1.1032.x64.zip](installers/Everything-1.4.1.1032.x64.zip) | 1,906,504 | 解压运行；NTFS索引仍需相应服务或管理员权限 | 是 |
| 64位精简安装版 | [Everything-1.4.1.1032.x64.Lite-Setup.exe](installers/Everything-1.4.1.1032.x64.Lite-Setup.exe) | 1,959,640 | 只需搜索界面，不使用IPC及相关服务端功能 | 否 |

这些文件是同一版本的不同发行形式；便携版是ZIP压缩包。Everything 1.4 Lite移除了IPC，因此官方ES、SDK以及本目录MCP不能与Lite连接。它也不包含ETP/FTP和HTTP服务器。详见[官方版本说明](https://www.voidtools.com/support/everything/installing_everything/)。

## MCP

[MCP备份与恢复说明](mcp/README.md)：everything-mcp 1.0.9、官方ES 1.1.1.39、固定依赖、配置模板、安装与验证脚本。已修复Windows中文路径编码问题，并在Codex重启后完成原生工具验证。

## 标准版安装建议

- 设置与数据保存到 `%APPDATA%\Everything`。
- NTFS索引选择“安装Everything服务”，让搜索窗口以普通用户权限运行。
- 保留自动索引固定卷，可按使用习惯开启开机自动启动、开始菜单及右键搜索入口。
- 开启后等待索引可用；供MCP使用时保持主程序驻留托盘。

## 文件校验与来源

- [SHA256SUMS](SHA256SUMS)：本目录三份发行包的摘要。
- [installer-manifest.json](installer-manifest.json)：版本文件名、大小、官方来源与核验状态。
- [官方1.4.1.1032校验文件](https://www.voidtools.com/Everything-1.4.1.1032.sha256)。
- [官方下载页](https://www.voidtools.com/downloads/)、[官方许可](LICENSE.txt)。

本目录为个人备份，非voidtools官方发布渠道；版权及许可归相应作者。MCP、ES和Everything的许可分别保留，不能将某个组件的许可笼统套用到全部软件。
