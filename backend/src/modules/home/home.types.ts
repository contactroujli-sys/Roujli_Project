export interface BusinessGrowthScore {
  score: number;
  change: number;
  period: string;
}

export interface Stat {
  label: string;
  value: string;
  change: string;
  isPositive: boolean;
}

export interface Business {
  id: string;
  name: string;
  category: string;
  imageUrl?: string | undefined;
  rating: number;
  reviews: number;
  location: string;
  isVerified: boolean;
}

export interface Offer {
  id: string;
  title: string;
  businessName: string;
  imageUrl?: string | undefined;
  discount: string;
  description: string;
  expiresAt: Date;
}

export interface BusinessInsight {
  id: string;
  title: string;
  description: string;
  category: string;
  createdAt: Date;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  businessCount: number;
}

export interface HomeData {
  growthScore: BusinessGrowthScore;
  stats: Stat[];
  trendingBusinesses: Business[];
  recommendedBusinesses: Business[];
  trendingOffers: Offer[];
  growingBusinesses: Business[];
  businessInsights: BusinessInsight[];
  categories: Category[];
}
