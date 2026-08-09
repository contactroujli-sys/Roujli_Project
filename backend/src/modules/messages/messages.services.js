import * as repo from "./messages.repository.js";
export async function getUserConversations(userId) {
    return repo.getUserConversations(userId);
}
export async function getOrCreateConversation(userId, businessId) {
    return repo.getOrCreateConversation(userId, businessId);
}
export async function getConversationMessages(conversationId) {
    return repo.getConversationMessages(conversationId);
}
export async function createMessage(data) {
    return repo.createMessage(data);
}
export async function markConversationAsRead(conversationId, role) {
    return repo.markConversationRead(conversationId, role);
}
//# sourceMappingURL=messages.services.js.map