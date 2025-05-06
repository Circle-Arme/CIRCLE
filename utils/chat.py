def allowed_types(level: str, user_type: str):
    """
    يرجع مجموعة أنواع الغرف المسموح بها لهذا المستخدم داخل المجتمع.
    """
    base = {"job_opportunities"}

    # منظمات التوظيف لا تدخل إلا فرص العمل
    if user_type == "organization":
        return base

    if level == "beginner":
        base.add("discussion_general")
    elif level == "advanced":
        base.add("discussion_advanced")
    else:                               # both
        base.update(("discussion_general", "discussion_advanced"))
    return base
