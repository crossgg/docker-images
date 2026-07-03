package vpngate

import (
	"sort"
	"strings"
)

type RecommendationSortPrimary string

const (
	SortPrimaryTotalUsersAsc RecommendationSortPrimary = "total_users_asc"
	SortPrimaryUptimeAsc     RecommendationSortPrimary = "uptime_asc"
	SortPrimarySessionsAsc   RecommendationSortPrimary = "sessions_asc"
	SortPrimaryPingAsc       RecommendationSortPrimary = "ping_asc"
	SortPrimaryScoreDesc     RecommendationSortPrimary = "score_desc"
	SortPrimarySpeedDesc     RecommendationSortPrimary = "speed_desc"
)

var defaultRecommendationSortOrder = []RecommendationSortPrimary{
	SortPrimaryTotalUsersAsc,
	SortPrimaryUptimeAsc,
	SortPrimarySessionsAsc,
	SortPrimaryPingAsc,
	SortPrimaryScoreDesc,
	SortPrimarySpeedDesc,
}

// IsRecommendedServer reports whether a server is eligible for automatic/recommended connection.
// Servers without OpenVPN config or without any observed online users are skipped.
func IsRecommendedServer(server Server) bool {
	return strings.TrimSpace(server.OpenVPNConfigDataBase64) != "" && server.TotalUsers > 0
}

func NormalizeRecommendationSortPrimary(primary string) RecommendationSortPrimary {
	switch RecommendationSortPrimary(strings.TrimSpace(primary)) {
	case SortPrimaryUptimeAsc:
		return SortPrimaryUptimeAsc
	case SortPrimarySessionsAsc:
		return SortPrimarySessionsAsc
	case SortPrimaryPingAsc:
		return SortPrimaryPingAsc
	case SortPrimaryScoreDesc:
		return SortPrimaryScoreDesc
	case SortPrimarySpeedDesc:
		return SortPrimarySpeedDesc
	default:
		return SortPrimaryTotalUsersAsc
	}
}

// SortServersByRecommendation sorts servers by connection preference.
// Lower total users, shorter uptime, and fewer active VPN sessions are preferred.
// Remaining fields act as deterministic fallbacks.
func SortServersByRecommendation(servers []Server) {
	SortServersByRecommendationWithPrimary(servers, SortPrimaryTotalUsersAsc)
}

// SortServersByRecommendationWithPrimary keeps the existing recommendation
// order but allows one field to be promoted to the first comparison slot.
func SortServersByRecommendationWithPrimary(servers []Server, primary RecommendationSortPrimary) {
	order := recommendationSortOrder(primary)
	sort.SliceStable(servers, func(i, j int) bool {
		for _, field := range order {
			if less, decided := compareServersByRecommendationField(servers[i], servers[j], field); decided {
				return less
			}
		}

		return servers[i].HostName < servers[j].HostName
	})
}

func recommendationSortOrder(primary RecommendationSortPrimary) []RecommendationSortPrimary {
	primary = NormalizeRecommendationSortPrimary(string(primary))
	order := make([]RecommendationSortPrimary, 0, len(defaultRecommendationSortOrder))
	order = append(order, primary)
	for _, field := range defaultRecommendationSortOrder {
		if field != primary {
			order = append(order, field)
		}
	}

	return order
}

func compareServersByRecommendationField(left, right Server, field RecommendationSortPrimary) (bool, bool) {
	switch field {
	case SortPrimaryTotalUsersAsc:
		if left.TotalUsers != right.TotalUsers {
			return left.TotalUsers < right.TotalUsers, true
		}
	case SortPrimaryUptimeAsc:
		if left.Uptime != right.Uptime {
			return left.Uptime < right.Uptime, true
		}
	case SortPrimarySessionsAsc:
		if left.NumVPNSessions != right.NumVPNSessions {
			return left.NumVPNSessions < right.NumVPNSessions, true
		}
	case SortPrimaryPingAsc:
		if left.Ping != right.Ping {
			if left.Ping <= 0 && right.Ping <= 0 {
				return false, false
			}
			if left.Ping <= 0 {
				return false, true
			}
			if right.Ping <= 0 {
				return true, true
			}

			return left.Ping < right.Ping, true
		}
	case SortPrimaryScoreDesc:
		if left.Score != right.Score {
			return left.Score > right.Score, true
		}
	case SortPrimarySpeedDesc:
		if left.Speed != right.Speed {
			return left.Speed > right.Speed, true
		}
	}

	return false, false
}
