# Instrucciones de desarrollo

## Principios
- Priorizar simplicidad, legibilidad y mantenibilidad.
- Resolver el problema con la solución más sencilla que sea correcta.
- Evitar sobreingeniería, abstracciones prematuras y duplicación.
- Respetar la arquitectura y las convenciones existentes.
- Realizar cambios mínimos y enfocados en la tarea.

## Código
- Usar español para nombres de variables y funciones.
- Crear clases solo cuando aporten una ventaja clara.
- Preferir funciones pequeñas con responsabilidades claras.
- Evitar comentarios redundantes y docstrings extensos.
- No añadir dependencias sin necesidad justificada.
- No ocultar errores ni introducir manejo de excepciones innecesario.

## Python
- Dependencias y ejecución con `uv` (`uv add`, `uv run`, `uv sync`); nunca `pip install` ni `poetry`.
- Tests solo con `pytest`; lint y formato solo con `ruff`. Ninguna otra herramienta (ni black, isort, flake8, mypy, pyright).

## Verificación
- Añadir o actualizar pruebas cuando corresponda.
- Ejecutar las pruebas y validaciones pertinentes: `verify` en la raíz del proyecto (en Python: `ruff check`, `ruff format --check`, `pytest`).
- No afirmar que algo funciona sin haberlo verificado.
- Informar brevemente los cambios y las verificaciones realizadas.
