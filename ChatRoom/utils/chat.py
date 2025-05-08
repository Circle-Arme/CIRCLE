def allowed_types(level: str, user_type: str) -> list[str]:
    base = ["job_opportunities"]
    if user_type == "organization":
        return base

    if level == "beginner":
        base.append("discussion_general")
    elif level == "advanced":
        base.append("discussion_advanced")
    else:  # both
        base.extend(["discussion_general", "discussion_advanced"])

    return base
