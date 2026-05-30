import re


def parse_price(value: str):
    if not value:
        return None
    cleaned = re.sub(r"[^0-9.]", "", value.replace(",", ""))
    if not cleaned:
        return None
    try:
        return float(cleaned)
    except ValueError:
        return None
