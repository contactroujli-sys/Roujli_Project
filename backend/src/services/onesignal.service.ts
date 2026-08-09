interface OneSignalNotificationPayload {
  userIds: string[];
  title: string;
  body: string;
  data?: Record<string, any>;
}

export async function sendOneSignalPush(payload: OneSignalNotificationPayload): Promise<boolean> {
  const appId = process.env.ONESIGNAL_APP_ID;
  const apiKey = process.env.ONESIGNAL_API_KEY;

  if (!appId || !apiKey || apiKey === "os_v2_app_placeholder_key") {
    console.warn("[OneSignal] Skipping push notification delivery: ONESIGNAL_API_KEY is not configured.");
    return false;
  }

  if (!payload.userIds || payload.userIds.length === 0) {
    return false;
  }

  try {
    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${apiKey}`,
      },
      body: JSON.stringify({
        app_id: appId,
        include_external_user_ids: payload.userIds,
        headings: { en: payload.title },
        contents: { en: payload.body },
        data: payload.data || {},
      }),
    });

    const result: any = await response.json();
    if (!response.ok) {
      console.error("[OneSignal Error]", result);
      return false;
    }

    console.log("[OneSignal Sent]", result);
    return true;
  } catch (err) {
    console.error("[OneSignal Exception]", err);
    return false;
  }
}
