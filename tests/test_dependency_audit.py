"""Dependency review preserves scope and follows all advisory pages."""
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from audit_dependencies import inventory, query


class DependencyAuditTests(unittest.TestCase):
    def test_scoped_nested_packages_and_exact_references(self):
        output = Path(__file__).resolve().parents[1] / ".output"
        output.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=output, ignore_cleanup_errors=True) as directory:
            root = Path(directory)
            self.assertTrue(root.resolve().is_relative_to(output.resolve()))
            (root / "src/app").mkdir(parents=True)
            (root / "src/app/package-lock.json").write_text(json.dumps({"packages": {
                "": {"version": "1.0.0"},
                "node_modules/parent/node_modules/@scope/child": {"version": "2.3.4"}}}))
            (root / "src/app/app.csproj").write_text('<Project><ItemGroup>'
                '<PackageReference Include="Exact" Version="1.2.3" />'
                '<PackageReference Include="Variable" Version="$(SharedVersion)" />'
                '</ItemGroup></Project>')
            packages = inventory(root)
            self.assertEqual({(p["package"]["name"], p["version"]) for p in packages},
                             {("@scope/child", "2.3.4"), ("Exact", "1.2.3")})

    def test_pagination_and_incomplete_results(self):
        packages = [{"package": {"name": "example", "ecosystem": "npm"},
                     "version": "1.0.0", "sources": ["synthetic"]}]
        calls = []
        def request(queries):
            calls.append(queries)
            self.assertNotIn("sources", queries[0])
            if "page_token" not in queries[0]:
                return {"results": [{"vulns": [{"id": "EXAMPLE-1"}], "next_page_token": "next"}]}
            return {"results": [{"vulns": [{"id": "EXAMPLE-2"}]}]}
        result = query(packages, request)
        self.assertEqual(len(calls), 2)
        self.assertEqual(result["packages"][0]["advisories"], ["EXAMPLE-1", "EXAMPLE-2"])
        with self.assertRaises(ValueError):
            query(packages, lambda queries: {"results": []})


if __name__ == "__main__":
    unittest.main()
