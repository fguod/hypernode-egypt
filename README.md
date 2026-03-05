# Simple Node

最简单的分布式节点程序，只有核心功能。

## 功能
- 连接到MQTT代理
- 响应简单命令
- 自动重连
- 最小依赖

## 安装
```powershell
# 下载安装脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fguod/hypernode-global/main/install.bat" -OutFile "install.bat"

# 运行
.\install.bat
```

## 直接运行
```powershell
# 下载主程序
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fguod/hypernode-global/main/node.py" -OutFile "node.py"

# 运行
python node.py
```

## 命令
- `ping` - 测试连接
- `info` - 获取节点信息
- `echo` - 回声测试
- `test` - 测试命令

## 要求
- Python 3.8+
- 网络连接