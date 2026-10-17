"""Windows checkouts must preserve Amiga script line endings."""
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent


@pytest.mark.parametrize("path", [
    "amiga/install/S/Start-Install",
    "amiga/install/S/Startup-Sequence",
    "amiga/amiga-os-3.2/S/Amiga-OS-3.2/Install-Adf-3.2.x",
])
def test_nested_amiga_scripts_checkout_as_lf(path):
    result = subprocess.run(
        ["git", "check-attr", "eol", "--", path],
        cwd=ROOT, capture_output=True, text=True, check=True,
    )
    assert result.stdout.strip().endswith(": eol: lf")
    assert b"\r" not in (ROOT / path).read_bytes()
