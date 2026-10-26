import pathlib
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "src"))
import monitor  # noqa: E402


class CleanTests(unittest.TestCase):
    def test_quita_colores(self):
        self.assertEqual(monitor.clean("\x1b[31mrojo\x1b[0m"), "rojo")

    def test_tapa_claves_conocidas(self):
        for secret in ("sk-or-v1-abcdefghijklmnop1234", "ghp_" + "a" * 30, "AKIA" + "A" * 16):
            self.assertNotIn(secret, monitor.clean(f"usando {secret} ahora"))

    def test_tapa_asignaciones_y_deja_el_nombre(self):
        out = monitor.clean("API_KEY=hunter2 y password: otra")
        self.assertNotIn("hunter2", out)
        self.assertNotIn("otra", out)
        self.assertIn("API_KEY=", out)

    def test_no_toca_texto_normal(self):
        self.assertEqual(monitor.clean("compilando 3 archivos"), "compilando 3 archivos")


class CaptureTests(unittest.TestCase):
    def fake(self, code, out=""):
        return lambda *a, **k: subprocess.CompletedProcess(a, code, stdout=out, stderr="")

    def test_sesion_inexistente(self):
        self.assertIsNone(monitor.capture("x", 5, run=self.fake(1)))

    def test_ultimas_lineas_sin_vacias(self):
        text = "\n".join(["uno", "", "dos", "tres", ""])
        self.assertEqual(monitor.capture("x", 2, run=self.fake(0, text)), "dos\ntres")


class RenderTests(unittest.TestCase):
    def test_escapa_html(self):
        page = monitor.render({"a": "<script>alert(1)</script>"}, 30, 0)
        self.assertNotIn("<script>alert", page)
        self.assertIn("&lt;script&gt;", page)

    def test_refresco_y_estados(self):
        page = monitor.render({"a": None, "b": ""}, 45, 0)
        self.assertIn('content="45"', page)
        self.assertIn("no está corriendo", page)
        self.assertIn("(sin salida)", page)

    def test_pausa_no_muestra_contenido(self):
        page = monitor.render({"a": "secreto"}, 30, 0, paused=True)
        self.assertNotIn("secreto", page)
        self.assertIn("En pausa", page)

    def test_escritura_atomica(self):
        with tempfile.TemporaryDirectory() as d:
            target = pathlib.Path(d) / "site" / "index.html"
            monitor.write_atomic(target, "hola")
            self.assertEqual(target.read_text(encoding="utf-8"), "hola")
            self.assertEqual([p.name for p in target.parent.iterdir()], ["index.html"])


if __name__ == "__main__":
    unittest.main()
