PAIRS = [("""    # Fases del camino base (NN-) y del track (ssNN-); la historia no es una fase.
    CAPITULO_RE = re.compile(r"^(?:ss)?(\\d{2})-.*\\.md$")
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("historia", "estructura")""",
"""    # Fases del camino base (NN-) y del track (ssNN-); la historia y la convención de git del lector
    # (00-convencion-de-git-y-tags.md, del 07/10/2026) no son fases.
    CAPITULO_RE = re.compile(r"^(?:ss)?(\\d{2})-.*\\.md$")
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("historia", "estructura", "convencion")""")]
