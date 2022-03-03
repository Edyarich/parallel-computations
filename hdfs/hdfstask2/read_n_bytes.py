from hdfs import Config
import sys


hdfs_file = sys.argv[1]
client = Config().get_client()
bytes_to_read = 10
content = ''

with client.read(hdfs_file, length=bytes_to_read, encoding='utf-8') as reader:
    content = reader.read()

print(content)
