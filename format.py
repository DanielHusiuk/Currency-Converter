import re
with open('dump.txt', 'r') as f:
    text = f.read()

lines = text.split('\n')
out = []
started = False
for l in lines:
    if not started and "<?xml" in l:
        started = True
    if started:
        # Check if line starts with "<number>:"
        match = re.match(r'^\d+:\s(.*)', l)
        if match:
            out.append(match.group(1))
        elif l.strip() == "The above content shows the entire, complete file contents of the requested file.":
            pass
        else:
            out.append(l)

with open('Currency converter/View/Base.lproj/Main.storyboard', 'w') as f:
    f.write('\n'.join(out))
print("Restored!")
