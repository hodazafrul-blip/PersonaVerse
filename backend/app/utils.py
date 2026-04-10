def calculate_stage(score: int) -> str:
    """
    Returns the relationship stage name based on the current affinity score.
    """
    if score >= 1000:
        return "Partner"
    if score >= 500:
        return "Romantic"
    if score >= 200:
        return "Close Friend"
    if score >= 50:
        return "Friend"
    return "Stranger"
