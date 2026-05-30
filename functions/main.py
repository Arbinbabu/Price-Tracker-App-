import datetime
import hashlib
import json
from typing import Any, Dict

import firebase_admin
from firebase_admin import firestore

from notifications.alert_checker import check_and_send_alerts
from scraper.daraz_scraper import extract_product_id, is_valid_daraz_url, scrape_daraz_product

if not firebase_admin._apps:
    firebase_admin.initialize_app()

db = firestore.client()


def _cors_headers() -> Dict[str, str]:
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
    }


def add_product_http(request):
    if request.method == "OPTIONS":
        return ("", 204, _cors_headers())

    headers = _cors_headers()
    if request.method != "POST":
        return ({"success": False, "error": "Only POST allowed"}, 405, headers)

    payload = request.get_json(silent=True) or {}
    url = payload.get("url", "").strip()
    user_id = payload.get("userId", "").strip()

    if not url or not user_id:
        return ({"success": False, "error": "url and userId are required"}, 400, headers)
    if not is_valid_daraz_url(url):
        return ({"success": False, "error": "Invalid Daraz Nepal URL"}, 400, headers)

    product_id = extract_product_id(url) or hashlib.md5(url.encode("utf-8")).hexdigest()
    product_ref = db.collection("products").document(product_id)
    user_ref = db.collection("users").document(user_id)

    existing = product_ref.get()
    now = firestore.SERVER_TIMESTAMP

    if existing.exists:
        product_data = existing.to_dict() or {}
        product_ref.set({"trackedByCount": firestore.Increment(1), "lastScraped": now}, merge=True)
    else:
        scraped = scrape_daraz_product(url)
        if not scraped.get("success"):
            return ({"success": False, "error": scraped.get("error", "Failed scraping")}, 502, headers)

        price = float(scraped["price"])
        product_data = {
            "productId": product_id,
            "name": scraped["name"],
            "url": url,
            "imageUrl": scraped.get("imageUrl", ""),
            "platform": "daraz",
            "currentPrice": price,
            "highestPrice": price,
            "lowestPrice": price,
            "lastScraped": now,
            "createdAt": now,
            "trackedByCount": 1,
        }
        product_ref.set(product_data)
        history_ref = product_ref.collection("priceHistory").document()
        history_ref.set(
            {
                "historyId": history_ref.id,
                "productId": product_id,
                "price": price,
                "timestamp": now,
                "source": "add_product_http",
            }
        )

    user_ref.set({"trackedProducts": firestore.ArrayUnion([product_id])}, merge=True)
    return ({"success": True, "productId": product_id, "product": product_data}, 200, headers)


def scheduled_price_update(event: Dict[str, Any], context: Any):
    products = db.collection("products").stream()
    for product_doc in products:
        product = product_doc.to_dict() or {}
        url = product.get("url")
        if not url:
            continue

        scraped = scrape_daraz_product(url)
        if not scraped.get("success"):
            continue

        new_price = float(scraped["price"])
        now = firestore.SERVER_TIMESTAMP
        product_ref = db.collection("products").document(product_doc.id)

        current = float(product.get("currentPrice", new_price))
        highest = float(product.get("highestPrice", new_price))
        lowest = float(product.get("lowestPrice", new_price))

        product_ref.update(
            {
                "currentPrice": new_price,
                "highestPrice": max(highest, new_price),
                "lowestPrice": min(lowest, new_price),
                "lastScraped": now,
            }
        )

        history_ref = product_ref.collection("priceHistory").document()
        history_ref.set(
            {
                "historyId": history_ref.id,
                "productId": product_doc.id,
                "price": new_price,
                "timestamp": now,
                "source": "scheduled_price_update",
            }
        )

        if new_price <= current:
            check_and_send_alerts(
                db=db,
                product_id=product_doc.id,
                product_name=product.get("name", "Tracked Product"),
                new_price=new_price,
            )

    return "ok"
