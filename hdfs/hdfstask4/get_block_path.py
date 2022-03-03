import subprocess
import sys


key_str = "Block replica"

block_id = sys.argv[1]
out = subprocess.Popen(['hdfs', 'fsck', '-blockId', block_id, '2>/dev/null'],
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
stdout, stderr = out.communicate()
lines = stdout.decode("utf-8").split("\n")
lines.reverse()

target_line = ''
for line in lines:
    if key_str in line:
        target_line = line
        break

if (target_line == ''):
    print("Block was not found")
    sys.exit(0)

node_name_start = target_line.find(': ') + 2
node_name_end = node_name_start + target_line[node_name_start:].find('/')
node_name = target_line[node_name_start:node_name_end]

ssh_dest = 'hdfsuser@' + node_name

proc = subprocess.Popen(['sudo', '-u', 'hdfsuser', 'ssh', ssh_dest, 'find', '/', '2>/dev/null', '-name', block_id],
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
proc_out, proc_err = proc.communicate()
proc_lines = proc_out.decode("utf-8").split("\n")

datanode_path = proc_lines[0]
print(node_name, ':', datanode_path, sep='')

