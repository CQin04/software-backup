# Everything MCP 本机备份

将Everything索引接入支持MCP的AI客户端，采用stdio通信。上游为 [elis132/everything-mcp](https://github.com/elis132/everything-mcp)，本备份固定为1.0.9；通过官方ES 1.1.1.39命令行连接Everything。没有修改上游Python源码。

2026-10-23已在Windows x64、Python 3.12.14、Everything 1.4.1.1032、MCP SDK 2.3.0下验证。Codex重启后五个原生MCP工具均已实际调用，中文完整路径与文件元数据正常。编码修正与验证边界见[修改与验证记录](修改与验证记录.md)。

## 备份内容

- `packages/`：原始MCP wheel和官方ES压缩包，摘要见 `SHA256SUMS`。
- `requirements.lock.txt`：该Windows/Python 3.12环境的完整固定版本，MCP从本地wheel安装，其他依赖从PyPI获取。
- `install.ps1`：在本目录创建独立环境、安装依赖及提取ES；不会替换整个Codex配置。
- `codex-config.example.toml`：可合并的配置模板，路径必须换成实际安装位置。
- `verify-mcp.py`：只用自行生成的临时中文测试文件验证五个工具，不扫描私人文件。
- `licenses/`：MCP和ES上游MIT许可证。Everything主程序的许可另见上一级说明。

没有收录个人文件、账号凭据、完整Codex配置、虚拟环境、缓存或未脱敏的查询日志。依赖恢复需要联网；此包不声称可以完全离线安装全部Python依赖。

## 恢复

1. 从[Everything说明](../README.md)选择标准安装版或便携版，启动Everything并等索引可用；Lite精简版没有IPC接口，不能用于此MCP。
2. 准备Python 3.12 x64。在PowerShell进入本目录，使用真实Python路径执行：

```powershell
.\install.ps1 -PythonPath 'C:\Path\To\Python312\python.exe'
.\.venv\Scripts\python.exe -B .\verify-mcp.py
```

3. 确认测试 `passed=true` 后注册到Codex；下面命令只增加名为 `everything` 的MCP服务器，不复制其他个人设置。如果已有同名接口，应先检查现有配置，避免意外改用别的目录。

```powershell
$mcpRoot = (Get-Location).Path
codex mcp add everything --env "EVERYTHING_ES_PATH=$mcpRoot\bin\es.exe" --env 'EVERYTHING_MAX_RESULTS_CAP=200' --env 'PYTHONUTF8=0' --env 'PYTHONIOENCODING=utf-8' -- "$mcpRoot\.venv\Scripts\python.exe" -B -m everything_mcp
codex mcp get everything --json
```

可按 `codex-config.example.toml` 将该服务启动超时设为30秒、工具超时设为45秒。重新打开Codex后再实际调用一次；Everything主程序需要在后台运行，仅启动索引服务不足以代替IPC客户端。

## 工具

| 名称 | 用途 |
| --- | --- |
| `everything_search` | 名称、路径、扩展名等查询 |
| `everything_search_by_type` | 按文档、图片、代码、压缩包等类型查询 |
| `everything_find_recent` | 查近期修改文件 |
| `everything_file_details` | 元数据与可选正文预览 |
| `everything_count_stats` | 数量与大小统计 |

文件名及路径搜索使用索引。Everything 1.4的全文等慢查询会读取候选文件，应先限定目录及类型。MCP上限设为200条，日常查找无需开启正文预览。

## 来源

[MCP项目](https://github.com/elis132/everything-mcp) · [MCP 1.0.9包](https://pypi.org/project/everything-mcp/1.0.9/) · [ES 1.1.1.39发布](https://github.com/voidtools/ES/releases/tag/1.1.1.39) · [官方CLI文档](https://www.voidtools.com/support/everything/command_line_interface/) · [Codex MCP文档](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)

