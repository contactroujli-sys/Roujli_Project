export const API_URL = import.meta.env["VITE_API_URL"] || "http://localhost:5000";

export function getAccessToken() {
  return localStorage.getItem("roujli_access_token");
}

export function getRefreshToken() {
  return localStorage.getItem("roujli_refresh_token");
}

export function setTokens(accessToken: string, refreshToken: string) {
  localStorage.setItem("roujli_access_token", accessToken);
  localStorage.setItem("roujli_refresh_token", refreshToken);
}

export function clearTokens() {
  localStorage.removeItem("roujli_access_token");
  localStorage.removeItem("roujli_refresh_token");
}

export async function fetchApi(path: string, options: RequestInit = {}) {
  let accessToken = getAccessToken();

  const headers = new Headers(options.headers);
  if (accessToken) {
    headers.set("Authorization", `Bearer ${accessToken}`);
  }
  if (!headers.has("Content-Type") && !(options.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }

  const url = `${API_URL}${path}`;
  let response = await fetch(url, { ...options, headers });

  if (response.status === 401 && getRefreshToken()) {
    // Try to refresh token
    const refreshRes = await fetch(`${API_URL}/api/auth/refresh-token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: getRefreshToken() }),
    });

    if (refreshRes.ok) {
      const data = await refreshRes.json();
      setTokens(data.accessToken, data.refreshToken);
      accessToken = data.accessToken;

      // Retry original request
      headers.set("Authorization", `Bearer ${accessToken}`);
      response = await fetch(url, { ...options, headers });
    } else {
      clearTokens();
      // Only reload if we are not already on the login page
      if (window.location.pathname !== "/login") {
        window.location.href = "/login";
      }
    }
  }

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    throw new Error(data?.message || "API request failed");
  }

  return data;
}
