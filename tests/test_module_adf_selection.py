"""Exercise the actual template's selection block without an Amiga runtime."""
import re
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / 'amiga/amiga-os-3.2/S/Amiga-OS-3.2/Adf-Template'
MODELS = ('A500', 'A600', 'A1200', 'A2000', 'A3000', 'A4000D', 'A4000T', 'CD32')


def selected(disk, adf, preference):
    source = SCRIPT.read_text().split('; quit, if detect disk')[0]
    source = source.replace('{disk}', disk).replace('{adffile}', adf)
    variables = {'modulesname': 'STALE'}
    active = [True]
    for line in source.splitlines():
        line = line.strip()
        if line == 'ENDIF':
            active.pop()
            continue
        if line.startswith('IF '):
            if ' EXISTS ' in line:
                condition = preference is not None
            else:
                expression = re.sub(r'\$(\w+)', lambda m: variables.get(m[1], ''), line)
                match = re.fullmatch(r'IF (NOT )?"(.*)" EQ "(.*)"', expression)
                assert match, expression
                condition = (match[2].lower() == match[3].lower()) != bool(match[1])
            active.append(active[-1] and condition)
        elif active[-1]:
            match = re.fullmatch(r'set(?:env)? (\w+) "(.*)"', line)
            if match:
                value = match[2]
                variables[match[1]] = (preference or '') if value.startswith('`Type ') else value
            elif line == 'SKIP adfend':
                return False, variables['modulesname']
    return True, variables['modulesname']


class ModuleSelectionTests(unittest.TestCase):
    def test_all_models_and_releases(self):
        for disk, version in (('Modules', '32'), ('Modules3.2.1', '321'), ('Modules3.2.3', '323')):
            for choice in (*MODELS, '', 'invalid', None):
                preference = None if choice is None else f'Amiga-OS-32-{choice}-ADF'
                for model in MODELS:
                    with self.subTest(disk=disk, choice=choice, model=model):
                        adf = f'INSTALLDIR:Temp/Amiga-OS/amiga-os-{version}-modules-{model.lower()}.adf'
                        accepted, name = selected(disk, adf, preference)
                        self.assertEqual(accepted, choice == model)
                        self.assertEqual(name, choice if choice in MODELS else '')

    def test_other_disks_are_unaffected(self):
        for disk in ('Install', 'Workbench', 'Update3.2.3', 'Classes3.2.3', 'Locale3.2.3'):
            self.assertTrue(selected(disk, 'example.adf', None)[0])

    def test_filter_precedes_disk_access(self):
        source = SCRIPT.read_text()
        self.assertNotIn('quit 0', source.lower())
        self.assertTrue(source.rstrip().endswith('LAB adfend'))
        self.assertLess(source.index('SKIP adfend'), source.index('diskwiz'))
        self.assertLess(source.index('SKIP adfend'), source.index('echo "{label}..."'))


if __name__ == '__main__':
    unittest.main()
