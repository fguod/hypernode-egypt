#!/usr/bin/env python3
"""
Test Node - Absolute simplest version
"""

import sys
import platform
import uuid
import time

print("=" * 50)
print("Test Node v1.0")
print("=" * 50)

# Basic info
node_id = "TEST-" + str(uuid.uuid4())[:8].upper()
print(f"Node ID: {node_id}")
print(f"System: {platform.system()}")
print(f"Python: {platform.python_version()}")
print(f"Time: {time.ctime()}")
print("=" * 50)

# Try to import MQTT
try:
    import paho.mqtt.client as mqtt
    print("✅ paho-mqtt is installed")
    
    # Simple test connection
    client = mqtt.Client(client_id=node_id)
    print("Testing MQTT connection...")
    
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("✅ Connected to MQTT")
        else:
            print(f"❌ Connection failed: {rc}")
    
    client.on_connect = on_connect
    client.connect("broker.emqx.io", 1883, 60)
    client.loop_start()
    
    # Send test message
    client.publish(f"test/{node_id}/hello", "Test node is running")
    print("📤 Test message sent")
    
    # Wait a bit
    time.sleep(2)
    client.loop_stop()
    client.disconnect()
    
except ImportError:
    print("❌ paho-mqtt not installed")
    print("Install with: pip install paho-mqtt")
    
except Exception as e:
    print(f"⚠️  Error: {e}")

print("=" * 50)
print("Test complete!")
print("Press Enter to exit...")
input()