import React, { createContext, useContext, useState, useEffect, type ReactNode } from "react";
import { getAccessToken, clearTokens, setTokens, API_URL } from "./api";

export interface User {
  id: string;
  email: string;
  role: string;
  firstName?: string;
  lastName?: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (data: { user: User; tokens: { accessToken: string; refreshToken: string } }) => void;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const initAuth = async () => {
      const token = getAccessToken();
      if (token) {
        try {
          const payload = JSON.parse(atob((token as string).split(".")[1] || ""));
          if (payload.role !== "ADMIN") {
            clearTokens();
            setUser(null);
          } else {
            setUser({
              id: payload.userId,
              email: payload.email,
              role: payload.role,
            });
            // Fetch full profile
            const { fetchApi } = await import("./api");
            const res = await fetchApi("/api/admin/profile");
            if (res.data) {
              setUser((prev: any) => ({
                ...prev,
                firstName: res.data.profile?.firstName,
                lastName: res.data.profile?.lastName,
                avatar: res.data.profile?.avatar,
              }));
            }
          }
        } catch (e) {
          clearTokens();
        }
      }
      setIsLoading(false);
    };
    initAuth();
  }, []);

  const login = (data: { user: User; tokens: { accessToken: string; refreshToken: string } }) => {
    setTokens(data.tokens.accessToken, data.tokens.refreshToken);
    setUser(data.user);
  };

  const logout = () => {
    clearTokens();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, isLoading, login, logout, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
