import subprocess
import sys
from hdfs import Config


key_str = "DatanodeInfoWithStorage["

path = sys.argv[1]
out = subprocess.Popen(['hdfs', 'fsck', path, '-files' ,'-blocks', '-locations'], 
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
stdout, stderr = out.communicate()
lines = stdout.decode("utf-8").split("\n")

target_line = ''
for line in lines:
    if line[:2] == '0.' and key_str in line:
        target_line = line
        break
        
if (target_line != ''):
    key_str_len = len(key_str)
    key_str_ind = target_line.find(key_str)
    
    ip_start = key_str_ind + key_str_len
    ip_end = ip_start + target_line[ip_start:].find(':')
    ip = target_line[ip_start:ip_end]
    print(ip)
