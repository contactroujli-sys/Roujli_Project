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

let refreshPromise: Promise<string | null> | null = null;

async function doRefreshToken(): Promise<string | null> {
  const currentRefreshToken = getRefreshToken();
  if (!currentRefreshToken) return null;

  try {
    const refreshRes = await fetch(`${API_URL}/api/auth/refresh-token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: currentRefreshToken }),
    });

    if (refreshRes.ok) {
      const resData = await refreshRes.json();
      const tokens = resData?.data;
      if (tokens?.accessToken && tokens?.refreshToken) {
        setTokens(tokens.accessToken, tokens.refreshToken);
        return tokens.accessToken as string;
      }
    }
  } catch (err) {
    console.error("Token refresh failed:", err);
  }

  clearTokens();
  if (window.location.pathname !== "/login") {
    window.location.href = "/login";
  }
  return null;
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
    if (!refreshPromise) {
      refreshPromise = doRefreshToken().finally(() => {
        refreshPromise = null;
      });
    }

    const newAccessToken = await refreshPromise;
    if (newAccessToken) {
      headers.set("Authorization", `Bearer ${newAccessToken}`);
      response = await fetch(url, { ...options, headers });
    }
  }

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    throw new Error(data?.message || "API request failed");
  }

  return data;
}
