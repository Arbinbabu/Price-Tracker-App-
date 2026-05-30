import datetime

from firebase_admin import firestore, messaging


def check_and_send_alerts(db, product_id: str, product_name: str, new_price: float):
    now = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc)
    alerts = (
        db.collection("alerts")
        .where("productId", "==", product_id)
        .where("isActive", "==", True)
        .where("targetPrice", ">=", new_price)
        .stream()
    )

    for alert_doc in alerts:
      alert = alert_doc.to_dict() or {}
      user_id = alert.get("userId")
      if not user_id:
          continue

      last_notified = alert.get("lastNotified")
      if last_notified is not None:
          if hasattr(last_notified, "to_datetime"):
              last_notified = last_notified.to_datetime()
          if hasattr(last_notified, "replace") and (now - last_notified).total_seconds() < 86400:
              continue

      user_doc = db.collection("users").document(user_id).get()
      user = user_doc.to_dict() or {}
      token = user.get("fcmToken")
      if not token:
          continue

      messaging.send(
          messaging.Message(
              token=token,
              notification=messaging.Notification(
                  title="Price Drop Alert!",
                  body=(
                      f"{product_name} is now NPR {new_price:.0f} — "
                      f"your target was NPR {float(alert.get('targetPrice', 0)):.0f}"
                  ),
              ),
              data={"productId": product_id},
          )
      )

      alert_doc.reference.update({"lastNotified": firestore.SERVER_TIMESTAMP})
