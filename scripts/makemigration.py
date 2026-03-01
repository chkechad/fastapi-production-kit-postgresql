"""Create an Alembic migration with Django-style sequential naming.

Usage:
    python scripts/makemigration.py "add user bio"
    python scripts/makemigration.py "create posts table" --empty
"""

import re
import subprocess
from pathlib import Path

import typer

app = typer.Typer(help="Alembic migration helper with Django-style naming.")

VERSIONS_DIR = Path("src/migrations/versions")


def get_next_number() -> str:
    """Compute the next migration number based on existing files."""
    existing = sorted(f.name for f in VERSIONS_DIR.glob("[0-9]*.py") if not f.name.startswith("__"))

    if not existing:
        return "0001"

    last = existing[-1]
    match = re.match(r"^(\d+)_", last)
    if not match:
        return "0001"

    return str(int(match.group(1)) + 1).zfill(4)


def slugify(message: str) -> str:
    """Convert a message to a snake_case slug."""
    slug = message.lower().strip()
    slug = re.sub(r"[^\w\s]", "", slug)
    slug = re.sub(r"\s+", "_", slug)
    return slug


@app.command()
def makemigration(
    message: str = typer.Argument(..., help="Migration description, e.g. 'add user bio'"),
    empty: bool = typer.Option(False, "--empty", help="Create an empty migration (no autogenerate)"),
) -> None:
    """Create a new Alembic migration with Django-style sequential naming."""
    VERSIONS_DIR.mkdir(parents=True, exist_ok=True)

    number = get_next_number()
    slug = slugify(message)
    filename_prefix = f"{number}_{slug}"

    typer.echo(f"Creating migration: {typer.style(filename_prefix + '.py', fg=typer.colors.CYAN)}")

    cmd = ["uv", "run", "alembic", "revision", "--message", message]
    if not empty:
        cmd.append("--autogenerate")

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        typer.echo(typer.style(result.stderr, fg=typer.colors.RED), err=True)
        raise typer.Exit(code=result.returncode)

    # Find the latest generated file and rename it
    generated = sorted(
        (f for f in VERSIONS_DIR.glob("*.py") if not f.name.startswith("__")),
        key=lambda f: f.stat().st_mtime,
    )

    if not generated:
        typer.echo(typer.style("❌ No migration file was generated.", fg=typer.colors.RED), err=True)
        raise typer.Exit(code=1)

    latest = generated[-1]

    if latest.name.startswith(f"{number}_"):
        typer.echo(typer.style(f"✅ Migration created: {latest.name}", fg=typer.colors.GREEN))
        return

    new_path = VERSIONS_DIR / f"{filename_prefix}.py"
    latest.rename(new_path)
    typer.echo(typer.style(f"✅ Migration created: {new_path.name}", fg=typer.colors.GREEN))


if __name__ == "__main__":
    app()
