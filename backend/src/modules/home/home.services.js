// ─── Get Home Data ─────────────────────────────────────────────────────────
export async function getHomeData(userId) {
    // In a real application, this would fetch data from the database
    // For now, we return mock data
    return {
        growthScore: {
            score: 87,
            change: 12,
            period: "month",
        },
        stats: [
            {
                label: "Total Views",
                value: "12.4K",
                change: "+18%",
                isPositive: true,
            },
            {
                label: "Leads",
                value: "342",
                change: "+24%",
                isPositive: true,
            },
            {
                label: "Revenue",
                value: "$8.5K",
                change: "+15%",
                isPositive: true,
            },
        ],
        trendingBusinesses: [
            {
                id: "1",
                name: "TechSpark Solutions",
                category: "Technology",
                rating: 4.9,
                reviews: 128,
                location: "Riyadh, SA",
                isVerified: true,
            },
            {
                id: "2",
                name: "GreenLeaf Organics",
                category: "Retail",
                rating: 4.7,
                reviews: 95,
                location: "Jeddah, SA",
                isVerified: true,
            },
        ],
        recommendedBusinesses: [
            {
                id: "3",
                name: "Apex Digital Agency",
                category: "Marketing",
                rating: 4.8,
                reviews: 74,
                location: "Dubai, UAE",
                isVerified: true,
            },
        ],
        trendingOffers: [
            {
                id: "1",
                title: "30% Off First Consulting Session",
                businessName: "Apex Digital Agency",
                discount: "30% OFF",
                description: "Special discount for ROUJLI users",
                expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
            },
        ],
        growingBusinesses: [
            {
                id: "4",
                name: "Nova Logistics",
                category: "Logistics",
                rating: 4.9,
                reviews: 210,
                location: "Dammam, SA",
                isVerified: true,
            },
        ],
        businessInsights: [
            {
                id: "1",
                title: "Weekly Market Analysis",
                description: "Insights on market growth in Q3",
                category: "Finance",
                createdAt: new Date(),
            },
        ],
        categories: [
            {
                id: "0",
                name: "All",
                icon: "all",
                businessCount: 150,
            },
            {
                id: "1",
                name: "Technology",
                icon: "technology",
                businessCount: 42,
            },
            {
                id: "2",
                name: "Finance",
                icon: "finance",
                businessCount: 28,
            },
            {
                id: "3",
                name: "Retail",
                icon: "retail",
                businessCount: 35,
            },
        ],
    };
}
//# sourceMappingURL=home.services.js.map