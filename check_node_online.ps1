# 检查HyperNode节点在线状态脚本
# 节点ID: COMPLETE-8199DFB1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "检查HyperNode节点在线状态" -ForegroundColor Yellow
Write-Host "节点ID: COMPLETE-8199DFB1" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 创建Python脚本检查节点状态
$pythonScript = @'
import paho.mqtt.client as mqtt
import json
import time
import sys

# 配置
NODE_ID = "COMPLETE-8199DFB1"
BROKER = "broker.emqx.io"
PORT = 1883
TIMEOUT = 8  # 等待响应的超时时间（秒）

# 存储响应的变量
ping_response_received = False
ping_response_time = None
heartbeat_received = False
last_heartbeat_time = None

def on_connect(client, userdata, flags, rc):
    """连接成功回调"""
    if rc == 0:
        print(f"✅ 已连接到MQTT代理: {BROKER}:{PORT}")
        # 订阅响应主题和心跳主题
        client.subscribe("hypernode/complete/responses")
        client.subscribe("hypernode/complete/heartbeat")
        print("✅ 已订阅响应和心跳主题")
    else:
        print(f"❌ 连接失败，错误码: {rc}")
        sys.exit(1)

def on_message(client, userdata, msg):
    """收到消息回调"""
    global ping_response_received, ping_response_time, heartbeat_received, last_heartbeat_time
    
    try:
        payload = msg.payload.decode('utf-8')
        data = json.loads(payload)
        
        topic = msg.topic
        
        if topic == "hypernode/complete/responses":
            # 检查是否是我们节点的响应
            if data.get("from") == NODE_ID and data.get("type") == "command_response":
                command = data.get("data", {}).get("command", "")
                if command == "ping":
                    ping_response_received = True
                    ping_response_time = time.time()
                    print("✅ 收到ping响应")
                    
        elif topic == "hypernode/complete/heartbeat":
            # 检查心跳消息
            if data.get("node_id") == NODE_ID:
                heartbeat_received = True
                last_heartbeat_time = time.time()
                print(f"💓 收到心跳消息: {data.get('timestamp', 'Unknown')}")
                
    except Exception as e:
        print(f"❌ 解析消息时出错: {e}")

def check_node_online():
    """检查节点在线状态"""
    print("🔍 检查节点在线状态...")
    
    # 创建MQTT客户端
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    
    try:
        # 连接MQTT代理
        client.connect(BROKER, PORT, 60)
        client.loop_start()
        
        # 等待连接建立
        time.sleep(2)
        
        # 方法1: 发送ping命令
        print("\n📡 方法1: 发送ping命令测试...")
        command = {
            "command": "ping",
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "request_id": "PING_TEST_" + str(int(time.time()))
        }
        
        topic = f"hypernode/complete/commands/{NODE_ID}"
        client.publish(topic, json.dumps(command))
        print(f"📤 Ping命令已发送到: {topic}")
        
        # 等待响应
        start_time = time.time()
        while (time.time() - start_time) < TIMEOUT:
            if ping_response_received:
                break
            time.sleep(0.5)
        
        # 方法2: 监听心跳消息
        print("\n💓 方法2: 监听心跳消息...")
        print("等待心跳消息 (5秒)...")
        time.sleep(5)
        
        # 显示检查结果
        print("\n" + "="*60)
        print("📊 NODE STATUS REPORT")
        print("="*60)
        
        current_time = time.strftime("%Y-%m-%d %H:%M:%S")
        print(f"检查时间: {current_time}")
        print(f"目标节点: {NODE_ID}")
        print(f"MQTT代理: {BROKER}:{PORT}")
        print()
        
        # Ping测试结果
        if ping_response_received:
            response_time_ms = int((ping_response_time - start_time) * 1000)
            print(f"✅ Ping测试: 成功")
            print(f"   响应时间: {response_time_ms}ms")
        else:
            print(f"❌ Ping测试: 失败 (超时)")
        
        # 心跳测试结果
        if heartbeat_received:
            time_since_heartbeat = int(time.time() - last_heartbeat_time)
            print(f"✅ 心跳检测: 成功")
            print(f"   最后心跳: {time_since_heartbeat}秒前")
        else:
            print(f"⚠️  心跳检测: 未收到心跳")
        
        print()
        print("="*60)
        
        # 总体状态判断
        if ping_response_received or heartbeat_received:
            print("🎉 节点状态: 🟢 在线")
            if ping_response_received and heartbeat_received:
                print("   节点完全正常，响应和心跳都正常")
            elif ping_response_received:
                print("   节点响应正常，但未检测到心跳")
            else:
                print("   节点有心跳，但未响应ping命令")
        else:
            print("❌ 节点状态: 🔴 离线或未响应")
            print("   可能原因:")
            print("   1. 节点未运行")
            print("   2. 网络连接问题")
            print("   3. MQTT代理连接问题")
            print("   4. 节点配置错误")
        
        print()
        print("🔧 建议操作:")
        if ping_response_received or heartbeat_received:
            print("   1. 节点运行正常，可以发送其他命令")
            print("   2. 使用 'get_hardware_info.ps1' 获取硬件信息")
            print("   3. 使用 'get_system_info.ps1' 获取系统信息")
        else:
            print("   1. 检查节点是否正在运行")
            print("   2. 检查网络连接")
            print("   3. 重启节点: cd %USERPROFILE%\.hypernode_complete && python hypernode_complete.py")
            print("   4. 检查防火墙设置")
        
        print("="*60)
            
    except Exception as e:
        print(f"❌ 检查节点状态时出错: {e}")
    finally:
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    print("="*60)
    print("HyperNode Node Status Checker")
    print(f"Target Node: {NODE_ID}")
    print(f"MQTT Broker: {BROKER}:{PORT}")
    print("="*60)
    print()
    
    check_node_online()
'@

# 保存Python脚本并执行
$scriptPath = "$env:TEMP\check_node.py"
$pythonScript | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host "执行节点状态检查..." -ForegroundColor Yellow
python $scriptPath

# 清理临时文件
Remove-Item $scriptPath -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "节点状态检查完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan