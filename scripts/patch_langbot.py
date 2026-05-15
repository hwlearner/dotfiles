import sys
f = sys.argv[1]
with open(f, encoding='utf-8') as fp:
    content = fp.read()
old = 'return await self.client.chat.completions.create(**args, extra_body=extra_body)'
new = 'extra_body["thinking"] = {"type": "disabled"};' + old
content = content.replace(old, new)
with open(f, 'w', encoding='utf-8') as fp:
    fp.write(content)
print('PATCHED')
