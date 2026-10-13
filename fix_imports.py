import os

base = r'C:\SAVING\GAWEAN GW\Capstone-Project\BuildHaus\lib\features'
count = 0
for root, dirs, files in os.walk(base):
    for fname in files:
        if not fname.endswith('.dart'):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
        new_content = content.replace("import '../../../core/", "import '../../../../core/")
        new_content = new_content.replace('import "../../../core/', 'import "../../../../core/')
        if new_content != content:
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Fixed: {fpath}')
            count += 1
print(f'Done - fixed {count} files')
