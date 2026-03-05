#!/usr/bin/env python3
"""
Simple Node - Minimal version
Just connect to MQTT and respond to commands
"""

import sys
import os
import platform
import json
import time
import uuid
import subprocess
from datetime import datetime

# Simple configuration
VERSION = "1.0.0"
NODE_ID = "NODE-" + str(uuid.uuid4())[:8].upper()
MQTT_BROKER = "broker.emqx.io"
MQTT_PORT = 1883

# Try to import MQTT
try:
    import paho.mqtt.client as mqtt
    MQTT_AVAILABLE = True
except ImportError:
    MQTT_AVAILABLE = False

def get_system_info():
    """Get basic system information"""
    return {
        "node_id": NODE_ID,
        "version": VERSION,
        "system": platform.system(),
        "hostname": platform.node(),
        "python_version": platform.python_version(),
        "timestamp": datetime.now().isoformat()
    }

def handle_command(command, data=None):
    """Handle simple commands"""
    if data is None:
        data = {}
    
    command = command.lower()
    print(f"Command: {command}")
    
    if command == "ping":
        return {"status": "ok", "message": "pong", "node_id": NODE_ID}
    
    elif command == "info":
        return {"status": "ok", "data": get_system_info()}
    
    elif command == "echo":
        text = data.get("text", "Hello")
        return {"status": "ok", "echo": text}
    
    elif command == "test":
        return {"status": "ok", "test": "success", "time": time.time()}
    
    else:
        return {"status": "error", "message": f"Unknown command: {command}"}

class SimpleNode:
    """Simple MQTT node"""
    
    def __init__(self):
        self.node_id = NODE_ID
        self.client = None
    
    def start(self):
        """Start the node"""
        print("=" * 50)
        print(f"Simple Node v{VERSION}")
        print(f"ID: {self.node_id}")
        print(f"MQTT: {MQTT_BROKER}:{MQTT_PORT}")
        print("=" * 50)
        
        if not MQTT_AVAILABLE:
            print("Error: paho-mqtt not installed")
            print("Install: pip install paho-mqtt")
            return
        
        # Create client
        self.client = mqtt.Client(client_id=self.node_id)
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        
        try:
            print("Connecting...")
            self.client.connect(MQTT_BROKER, MQTT_PORT, 60)
            
            print("Ready. Press Ctrl+C to stop.")
            print("=" * 50)
            
            self.client.loop_forever()
            
        except KeyboardInterrupt:
            print("\nStopping...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            if self.client:
                self.client.disconnect()
    
    def on_connect(self, client, userdata, flags, rc):
        """Connected to MQTT"""
        if rc == 0:
            print("Connected to MQTT")
            
            # Subscribe to commands
            topic = f"node/{self.node_id}/commands"
            client.subscribe(topic)
            print(f"Listening on: {topic}")
            
            # Send hello
            self.send_message("node/hello", {
                "node_id": self.node_id,
                "version": VERSION,
                "message": "Node started"
            })
        else:
            print(f"Connection failed: {rc}")
    
    def on_message(self, client, userdata, msg):
        """Received message"""
        try:
            data = json.loads(msg.payload.decode('utf-8'))
            command = data.get("command", "")
            
            if command:
                response = handle_command(command, data.get("data", {}))
                
                # Send response
                self.send_message(f"node/{self.node_id}/response", {
                    "command": command,
                    "response": response
                })
                
        except Exception as e:
            print(f"Message error: {e}")
    
    def send_message(self, topic, data):
        """Send message to MQTT"""
        if self.client:
            self.client.publish(
                topic,
                json.dumps(data, ensure_ascii=False),
                qos=1
            )

def main():
    """Main function"""
    node = SimpleNode()
    node.start()

if __name__ == "__main__":
    main()