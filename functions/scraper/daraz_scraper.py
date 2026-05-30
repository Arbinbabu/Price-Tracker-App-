import json
import re
from typing import Dict, Optional
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup

from scraper.utils import parse_price


def is_valid_daraz_url(url: str) -> bool:
    try:
        host = urlparse(url).netloc.lower()
        return "daraz.com.np" in host
    except Exception:
        return False


def extract_product_id(url: str) -> Optional[str]:
    match = re.search(r"-i(\d+)\.html", url)
    if match:
        return match.group(1)
    return None


def _parse_initial_state(soup: BeautifulSoup):
    for script in soup.find_all("script"):
        text = script.string or script.get_text() or ""
        if "__INITIAL_STATE__" not in text:
            continue
        match = re.search(r"__INITIAL_STATE__\s*=\s*(\{.*\})\s*;", text, flags=re.DOTALL)
        if not match:
            continue
        try:
            state = json.loads(match.group(1))
        except json.JSONDecodeError:
            continue

        serialized = json.dumps(state)
        price_match = re.search(r'"salePrice"\s*:\s*"?([0-9.,]+)"?', serialized)
        if not price_match:
            continue

        price = parse_price(price_match.group(1))
        if price is not None:
            name = soup.title.get_text(strip=True) if soup.title else "Daraz Product"
            image = ""
            image_match = re.search(r'"image"\s*:\s*"([^"]+)"', serialized)
            if image_match:
                image = image_match.group(1)
            return {"name": name, "price": price, "imageUrl": image}
    return None


def _parse_ld_json(soup: BeautifulSoup):
    for script in soup.find_all("script", attrs={"type": "application/ld+json"}):
        raw = script.string or script.get_text() or ""
        try:
            data = json.loads(raw)
        except Exception:
            continue

        offers = data.get("offers", {}) if isinstance(data, dict) else {}
        price = parse_price(str(offers.get("price", "")))
        if price is None:
            continue
        image = data.get("image", "") if isinstance(data, dict) else ""
        if isinstance(image, list):
            image = image[0] if image else ""
        return {
            "name": data.get("name", "Daraz Product"),
            "price": price,
            "imageUrl": image,
        }
    return None


def _parse_css_fallback(soup: BeautifulSoup):
    price_tag = soup.select_one(".pdp-price strong")
    price = parse_price(price_tag.get_text(strip=True) if price_tag else "")
    if price is None:
        return None
    image_tag = soup.select_one("meta[property='og:image']")
    title_tag = soup.select_one("meta[property='og:title']")
    return {
        "name": title_tag["content"] if title_tag and title_tag.has_attr("content") else "Daraz Product",
        "price": price,
        "imageUrl": image_tag["content"] if image_tag and image_tag.has_attr("content") else "",
    }


def scrape_daraz_product(url: str) -> Dict:
    try:
        response = requests.get(url, timeout=20, headers={"User-Agent": "Mozilla/5.0"})
        response.raise_for_status()
        soup = BeautifulSoup(response.text, "html.parser")

        result = _parse_initial_state(soup) or _parse_ld_json(soup) or _parse_css_fallback(soup)
        if not result:
            return {"success": False, "error": "Could not parse product details"}
        return {"success": True, **result}
    except Exception as exc:
        return {"success": False, "error": str(exc)}
