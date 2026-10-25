import json
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "src"))
from route import LONG_PROMPT_CHARS, Task, route  # noqa: E402

FIXTURES = pathlib.Path(__file__).resolve().parents[1] / "demo" / "fixtures" / "tasks.json"


def load():
    return {t["title"]: Task(t["title"], frozenset(t["tags"]), t.get("prompt_chars", 0), t.get("urgent", False))
            for t in json.loads(FIXTURES.read_text(encoding="utf-8"))}


class RouteTests(unittest.TestCase):
    def setUp(self):
        self.tasks = load()

    def test_credentials_stay_with_coordinator(self):
        self.assertEqual(route(self.tasks["Revisar una clave de API vencida"]).assistant, "coordinator")

    def test_production_never_leaves_coordinator(self):
        self.assertEqual(route(self.tasks["Reiniciar un servicio de producción"]).assistant, "coordinator")

    def test_sensitive_code_goes_to_builder_with_fictional_data(self):
        r = route(self.tasks["Escribir un conversor de informes de gastos"])
        self.assertEqual(r.assistant, "builder")
        self.assertTrue(r.needs_fictional_data)

    def test_short_public_goes_to_auxiliary(self):
        self.assertEqual(route(self.tasks["Sugerir nombre para un módulo"]).assistant, "auxiliary")

    def test_long_public_goes_to_builder(self):
        self.assertEqual(route(self.tasks["Comparar tres bibliotecas de gráficos (consigna larga)"]).assistant, "builder")

    # Bordes revisados
    def test_long_public_goes_to_builder_even_with_reserve_exhausted(self):
        t = Task("Consulta larga", frozenset({"research"}), 5200)
        self.assertEqual(route(t, usage_pct=90).assistant, "builder")

    def test_length_limit_is_strictly_greater(self):
        self.assertEqual(route(Task("x", frozenset({"research"}), LONG_PROMPT_CHARS)).assistant, "auxiliary")
        self.assertEqual(route(Task("x", frozenset({"research"}), LONG_PROMPT_CHARS + 1)).assistant, "builder")

    def test_unlabeled_stays_with_coordinator(self):
        self.assertEqual(route(Task("x", frozenset())).assistant, "coordinator")

    def test_unlabeled_never_goes_to_auxiliary(self):
        for usage in (0, 59, 60, 84, 85, 89, 90, 100):
            self.assertNotEqual(route(Task("x", frozenset()), usage_pct=usage).assistant, "auxiliary")

    def test_unlabeled_waits_when_reserve_exhausted_unless_urgent(self):
        self.assertEqual(route(Task("x", frozenset()), usage_pct=90).assistant, "queue")
        self.assertEqual(route(Task("x", frozenset(), urgent=True), usage_pct=90).assistant, "coordinator")

    def test_sensitive_ignores_usage_and_urgency(self):
        for urgent in (True, False):
            t = Task("x", frozenset({"credentials"}), urgent=urgent)
            self.assertEqual(route(t, usage_pct=95).assistant, "coordinator")


if __name__ == "__main__":
    unittest.main()
