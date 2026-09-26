import json

log_file = "/Users/daniel/.gemini/antigravity-ide/brain/91db657d-1c58-406f-9961-471c8e15f751/.system_generated/logs/transcript_full.jsonl"
found = False

with open(log_file, "r") as f:
    for line in f:
        try:
            data = json.loads(line)
            content = data.get("content", "")
            if "com.apple.InterfaceBuilder3" in content:
                print("Found match in type:", data.get("type"))
                # Write it out so I can inspect
                with open("dump.txt", "w") as out:
                    out.write(content)
                found = True
        except Exception:
            pass
