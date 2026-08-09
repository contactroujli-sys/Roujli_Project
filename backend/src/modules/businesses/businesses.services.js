import * as repo from "./businesses.repository.js";
export async function getBusinesses(query, userId) {
    return repo.listBusinesses(query, userId);
}
export async function getBusinessById(id, userId) {
    return repo.getBusinessById(id, userId);
}
export async function toggleSave(userId, businessId) {
    return repo.toggleSaveBusiness(userId, businessId);
}
export async function toggleFollow(userId, businessId) {
    return repo.toggleFollowBusiness(userId, businessId);
}
export async function getSaved(userId) {
    return repo.getSavedBusinesses(userId);
}
//# sourceMappingURL=businesses.services.js.map