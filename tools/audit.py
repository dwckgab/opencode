"""Auditoria do repo multi-agente: frontmatter, permissoes, referencias, inbox, JSONs, skills e segredos.

Uso:
    python3 tools/audit.py   (a partir da raiz do repo)
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
AD = ".opencode/agents"
files = sorted(os.path.basename(f) for f in glob.glob(AD + "/*.md"))
names = {f[:-3] for f in files}
print("agents:", len(files))
WL = {"read", "edit", "glob", "grep", "list", "bash", "task",
      "external_directory", "todowrite", "webfetch", "websearch",
      "lsp", "skill", "question", "doom_loop"}
errs = []


def fm(path):
    t = open(path, encoding="utf-8").read()
    assert t.startswith("---"), path + " sem frontmatter"
    parts = t.split("---")
    assert len(parts) >= 3, path + " sem fechamento ---"
    return parts[1]


for f in files:
    p = os.path.join(AD, f)
    body = fm(p)
    txt = open(p, encoding="utf-8").read()
    top = {k: True for k in re.findall(r"(?m)^([a-z_]+):", body)}
    for req in ("description", "mode"):
        if req not in top:
            errs.append(f + ": falta " + req)
    m = re.search(r"(?m)^mode:\s*(\S+)", body)
    if m and m.group(1) not in ("primary", "subagent", "all"):
        errs.append(f + ": mode invalido " + m.group(1))
    mt = re.search(r"(?m)^temperature:\s*(\S+)", body)
    if mt and not (0 <= float(mt.group(1)) <= 1):
        errs.append(f + ": temperature fora de 0-1")
    ms = re.search(r"(?m)^steps:\s*(\S+)", body)
    if ms and not (1 <= int(ms.group(1)) <= 1000):
        errs.append(f + ": steps fora de 1-1000")
    if "color" in top and not re.search(r'(?m)^color:\s*"?#[0-9a-fA-F]{6}"?', body):
        errs.append(f + ": color hex invalida")
    for key in re.findall(r"(?m)^  ([a-z_]+):", body):
        if key not in WL:
            errs.append(f + ": permission key invalida: " + key)
    for blk in ("edit", "bash", "task"):
        mb = re.search(r"(?m)^  " + blk + r":\n((?:    .*\n)+)", txt)
        if mb:
            keys = [k.strip().strip('"') for k in
                    re.findall(r"(?m)^    (\"[^\"]+\"|\S+):", mb.group(1))]
            if "*" in keys and keys[0] != "*":
                errs.append(f + ": bloco " + blk + " com * fora da 1a posicao: " + str(keys))
            vals = re.findall(r"(?m)^    \S.*:\s*(allow|ask|deny)\s*$", mb.group(1))
            if len(vals) != len(keys):
                errs.append(f + ": bloco " + blk + " com valor fora de allow/ask/deny")
    mt2 = re.search(r"(?m)^  task:\n((?:    .*\n)+)", txt)
    if mt2:
        for ref in re.findall(r"\"([^\"]+)\"", mt2.group(1)):
            if ref != "*" and ref not in names:
                errs.append(f + ": task referencia inexistente: " + ref)
    for ib in set(re.findall(r"inbox/([\w-]+)\.md", txt)):
        if ib != f[:-3]:
            errs.append(f + ": inbox de outro agente: " + ib)
    for leg in ("dev-frontend", "dev-backend"):
        if re.search("@" + leg + r"\b|\"" + leg + "\"", txt):
            errs.append(f + ": referencia legada: " + leg)

rm = open("README.md", encoding="utf-8").read()
for n in names:
    if n not in rm:
        errs.append("README nao menciona agente: " + n)
rm_lines = [line for line in rm.splitlines() if "Migração da v1" not in line]
rm_check = "\n".join(rm_lines)
for stale in ("(5 agentes)", "22 agentes"):
    if stale in rm_check:
        errs.append("README com contagem obsoleta: " + stale)
for bad in ("4 coordenadores", "22 agentes"):
    for f in files:
        if bad in open(os.path.join(AD, f), encoding="utf-8").read():
            errs.append(f + " com contagem obsoleta: " + bad)

try:
    json.load(open("opencode.json.example", encoding="utf-8"))
    print("opencode.json.example JSON OK")
except Exception as e:
    errs.append("opencode.json.example invalido: " + str(e))
for jf in ("opencode.mimo.json.example",):
    try:
        cfg = json.load(open(jf, encoding="utf-8"))
        assert "provider" in cfg and "mimo" in cfg["provider"], "sem provider mimo"
        assert "models" in cfg["provider"]["mimo"], "sem models"
        print(jf + " JSON OK")
    except Exception as e:
        errs.append(jf + " invalido: " + str(e))

for sd in glob.glob(".opencode/skills/*/SKILL.md"):
    name = os.path.basename(os.path.dirname(sd))
    t = open(sd, encoding="utf-8").read()
    assert t.startswith("---") and len(t.split("---")) >= 3, sd
    skfm = t.split("---")[1]
    nm = re.search(r"(?m)^name:\s*(\S+)", skfm)
    if not nm or nm.group(1) != name or not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", nm.group(1)):
        errs.append(sd + ": name invalido ou != pasta")
    if not re.search(r"(?m)^description:", skfm):
        errs.append(sd + ": sem description")
print("skills verificadas:", len(glob.glob(".opencode/skills/*/SKILL.md")))

sec = re.compile(r"(?i)ghp_[a-z0-9]{8,}|sk-[a-z0-9]{8,}|(api[_-]?key|password|secret)\s*[:=]\s*['\"][^'\"]{4,}['\"]")
for root, _, fs in os.walk("."):
    if ".git" in root:
        continue
    for fn in fs:
        p = os.path.join(root, fn)
        try:
            t = open(p, encoding="utf-8").read()
        except Exception:
            continue
        for hit in sec.findall(t):
            errs.append("possivel segredo em " + p + ": " + str(hit)[:20])

print("ERROS:" if errs else "AUDIT OK")
for e in errs:
    print(" -", e)
sys.exit(1 if errs else 0)
